import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["name", "newInput", "newForm"]

  // Constants for drag and drop behavior
  static DRAG_ENABLE_DELAY = 10 // milliseconds

  connect() {
    this.editingHabitId = null
    this.originalName = null
    this.setupDragAndDrop()
  }

  setupDragAndDrop() {
    const habitItems = this.element.querySelectorAll('.habit-item:not(.habit-item--new)')
    
    habitItems.forEach((item, index) => {
      const dragHandle = item.querySelector('.drag-handle')
      
      if (dragHandle) {
        // For desktop: Make the entire habit item draggable
        item.draggable = true
        
        // Desktop drag events - attach to the habit item
        item.addEventListener('dragstart', this.handleDragStart.bind(this))
        item.addEventListener('dragend', this.handleDragEnd.bind(this))
        
        // Prevent dragging unless initiated from drag handle
        item.addEventListener('mousedown', (event) => {
          if (!event.target.closest('.drag-handle')) {
            // Temporarily disable dragging if not starting from drag handle
            item.draggable = false
            // Re-enable dragging after a short delay
            setTimeout(() => { item.draggable = true }, this.constructor.DRAG_ENABLE_DELAY)
          }
        })
        
        
        // Mobile touch events - keep on drag handle for precise touch control
        dragHandle.addEventListener('touchstart', this.handleTouchStart.bind(this), { passive: false })
        dragHandle.addEventListener('touchmove', this.handleTouchMove.bind(this), { passive: false })
        dragHandle.addEventListener('touchend', this.handleTouchEnd.bind(this), { passive: false })
      }
    })
    
    // Add dragover and drop events to ALL habit items for desktop drag and drop
    habitItems.forEach((item) => {
      item.addEventListener('dragover', this.handleDragOver.bind(this))
      item.addEventListener('drop', this.handleDrop.bind(this))
    })
  }

  handleDragStart(event) {
    // For desktop drag: event.target is the habit-item itself
    this.draggedElement = event.target.classList.contains('habit-item') ? event.target : event.target.closest('.habit-item')
    this.draggedElement.classList.add('dragging')
    event.dataTransfer.effectAllowed = 'move'
    event.dataTransfer.setData('text/html', this.draggedElement.outerHTML)
  }

  handleDragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = 'move'
    
    const afterElement = this.getDragAfterElement(event.clientY)
    const draggingElement = this.element.querySelector('.dragging')
    const habitList = this.element.querySelector('.habit-list')
    
    if (afterElement == null) {
      habitList.appendChild(draggingElement)
    } else {
      habitList.insertBefore(draggingElement, afterElement)
    }
  }

  async handleDrop(event) {
    event.preventDefault()
    await this.updateHabitOrder()
  }

  handleDragEnd(event) {
    this.draggedElement.classList.remove('dragging')
    this.draggedElement = null
  }

  // Touch event handlers for mobile support
  handleTouchStart(event) {
    this.preventDefaultIfCancelable(event)
    
    this.draggedElement = event.target.closest('.habit-item')
    this.draggedElement.classList.add('dragging')
    
    // Store initial touch position
    this.initialTouchY = event.touches[0].clientY
    this.touchOffsetY = 0
  }

  handleTouchMove(event) {
    this.preventDefaultIfCancelable(event)
    
    if (!this.draggedElement) return
    
    const touch = event.touches[0]
    this.touchOffsetY = touch.clientY - this.initialTouchY
    
    // Visual feedback - move the element
    this.draggedElement.style.transform = `translateY(${this.touchOffsetY}px) rotate(2deg)`
    
    // Find the element we're hovering over
    const afterElement = this.getDragAfterElement(touch.clientY)
    const habitList = this.element.querySelector('.habit-list')
    
    if (afterElement == null) {
      habitList.appendChild(this.draggedElement)
    } else {
      habitList.insertBefore(this.draggedElement, afterElement)
    }
  }

  async handleTouchEnd(event) {
    this.preventDefaultIfCancelable(event)
    
    if (!this.draggedElement) return
    
    // Reset transform
    this.draggedElement.style.transform = ''
    this.draggedElement.classList.remove('dragging')
    
    // Update habit order
    await this.updateHabitOrder()
    
    this.draggedElement = null
    this.initialTouchY = null
    this.touchOffsetY = 0
  }

  getDragAfterElement(y) {
    const draggableElements = [...this.element.querySelectorAll('.habit-item:not(.dragging):not(.habit-item--new)')]
    
    return draggableElements.reduce((closest, child) => {
      const box = child.getBoundingClientRect()
      const offset = y - box.top - box.height / 2
      
      if (offset < 0 && offset > closest.offset) {
        return { offset: offset, element: child }
      } else {
        return closest
      }
    }, { offset: Number.NEGATIVE_INFINITY }).element
  }

  // Helper method to prevent default only if event is cancelable
  preventDefaultIfCancelable(event) {
    if (event.cancelable) {
      event.preventDefault()
    }
  }

  async updateHabitOrder() {
    const habitItems = [...this.element.querySelectorAll('.habit-item:not(.habit-item--new)')]
    
    // Build array of positions for batch update
    const positions = habitItems.map((item, index) => {
      const habitId = item.dataset.habitId
      if (!habitId) return null
      
      return {
        id: habitId,
        position: index + 1
      }
    }).filter(item => item !== null)
    
    if (positions.length === 0) return
    
    // Send single batch request to update all positions
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    
    // Get target year and month from data attributes
    const targetYear = this.element.dataset.targetYear
    const targetMonth = this.element.dataset.targetMonth
    
    try {
      const response = await fetch('/habits/positions', {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          positions: positions,
          target_year: targetYear,
          target_month: targetMonth
        }),
        // Keep request alive even if user navigates away
        keepalive: true
      })
      
      if (!response.ok) {
        console.error('Failed to update habit positions:', response.statusText)
      }
    } catch (error) {
      console.error('Error updating habit positions:', error)
    }
  }

  edit(event) {
    event.preventDefault()
    
    const nameElement = event.currentTarget
    const habitId = nameElement.dataset.habitId
    const currentName = nameElement.textContent.trim()
    
    // Cancel any existing edit
    if (this.editingHabitId) {
      this.cancelEdit()
    }
    
    // Create input field
    const input = document.createElement("input")
    input.type = "text"
    input.value = currentName
    input.className = "habit-input habit-input--inline"
    input.dataset.habitId = habitId
    
    // Force transparent background directly on the element
    input.style.background = "transparent"
    input.style.backgroundColor = "transparent"
    input.style.border = "none"
    input.style.outline = "none"
    input.style.boxShadow = "none"
    
    // Store original values
    this.editingHabitId = habitId
    this.originalName = currentName
    
    // Insert input after the habit name span, then hide the span
    nameElement.parentElement.insertBefore(input, nameElement.nextSibling)
    nameElement.style.display = "none"
    
    // Focus without selecting text
    input.focus()
    
    // Add event listeners
    input.addEventListener("blur", () => this.saveEdit(input))
    input.addEventListener("keydown", (e) => {
      if (e.key === "Enter") {
        e.preventDefault()
        this.saveEdit(input)
      } else if (e.key === "Escape") {
        e.preventDefault()
        this.cancelEditFromInput(input)
      }
    })
  }

  saveEdit(input) {
    const habitId = input.dataset.habitId
    const newName = input.value.trim()
    
    if (newName && newName !== this.originalName) {
      // Submit form to update habit
      const form = document.createElement("form")
      form.method = "POST"
      form.action = `/habits/${habitId}`
      form.style.display = "none"
      
      // Add CSRF token
      const csrfToken = document.querySelector('meta[name="csrf-token"]').content
      const csrfInput = document.createElement("input")
      csrfInput.type = "hidden"
      csrfInput.name = "authenticity_token"
      csrfInput.value = csrfToken
      form.appendChild(csrfInput)
      
      // Add method override for PATCH
      const methodInput = document.createElement("input")
      methodInput.type = "hidden"
      methodInput.name = "_method"
      methodInput.value = "PATCH"
      form.appendChild(methodInput)
      
      // Add habit name
      const nameInput = document.createElement("input")
      nameInput.type = "hidden"
      nameInput.name = "habit[name]"
      nameInput.value = newName
      form.appendChild(nameInput)
      
      document.body.appendChild(form)
      form.submit()
    } else {
      // Restore original if empty or unchanged
      this.cancelEditFromInput(input)
    }
  }

  cancelEdit() {
    if (this.editingHabitId) {
      const input = this.element.querySelector(`input[data-habit-id="${this.editingHabitId}"]`)
      if (input) {
        this.cancelEditFromInput(input)
      }
    }
  }

  cancelEditFromInput(input) {
    const nameElement = input.parentElement.querySelector('[data-inline-habit-editor-target="name"]')
    if (nameElement) {
      nameElement.style.display = ""
      input.remove()
    }
    this.editingHabitId = null
    this.originalName = null
  }

  createHabit(event) {
    // Let the form submit naturally
    const input = this.newInputTarget
    if (!input.value.trim()) {
      event.preventDefault()
    }
  }

  cancelNew() {
    if (this.hasNewInputTarget) {
      this.newInputTarget.value = ""
    }
  }
}