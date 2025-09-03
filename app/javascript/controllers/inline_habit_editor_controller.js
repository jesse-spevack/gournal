import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["name", "newInput", "newForm"]

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
        // Make drag handle draggable
        dragHandle.draggable = true
        
        // Desktop drag events
        dragHandle.addEventListener('dragstart', this.handleDragStart.bind(this))
        item.addEventListener('dragover', this.handleDragOver.bind(this))
        item.addEventListener('drop', this.handleDrop.bind(this))
        dragHandle.addEventListener('dragend', this.handleDragEnd.bind(this))
        
        // Mobile touch events
        dragHandle.addEventListener('touchstart', this.handleTouchStart.bind(this), { passive: false })
        dragHandle.addEventListener('touchmove', this.handleTouchMove.bind(this), { passive: false })
        dragHandle.addEventListener('touchend', this.handleTouchEnd.bind(this), { passive: false })
      }
    })
  }

  handleDragStart(event) {
    this.draggedElement = event.target.closest('.habit-item')
    this.draggedElement.classList.add('dragging')
    event.dataTransfer.effectAllowed = 'move'
    event.dataTransfer.setData('text/html', this.draggedElement.outerHTML)
  }

  handleDragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = 'move'
    
    const afterElement = this.getDragAfterElement(event.clientY)
    const draggingElement = this.element.querySelector('.dragging')
    
    if (afterElement == null) {
      this.element.appendChild(draggingElement)
    } else {
      this.element.insertBefore(draggingElement, afterElement)
    }
  }

  handleDrop(event) {
    event.preventDefault()
    this.updateHabitOrder()
  }

  handleDragEnd(event) {
    this.draggedElement.classList.remove('dragging')
    this.draggedElement = null
  }

  // Touch event handlers for mobile support
  handleTouchStart(event) {
    event.preventDefault()
    
    this.draggedElement = event.target.closest('.habit-item')
    this.draggedElement.classList.add('dragging')
    
    // Store initial touch position
    this.initialTouchY = event.touches[0].clientY
    this.touchOffsetY = 0
  }

  handleTouchMove(event) {
    event.preventDefault()
    
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

  handleTouchEnd(event) {
    event.preventDefault()
    
    if (!this.draggedElement) return
    
    // Reset transform
    this.draggedElement.style.transform = ''
    this.draggedElement.classList.remove('dragging')
    
    // Update habit order
    this.updateHabitOrder()
    
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

  updateHabitOrder() {
    const habitItems = [...this.element.querySelectorAll('.habit-item:not(.habit-item--new)')]
    
    // Update each habit's position individually using AJAX
    habitItems.forEach((item, index) => {
      const habitId = item.dataset.habitId
      if (!habitId) return
      
      const newPosition = index + 1
      
      // Use fetch to send AJAX request
      const csrfToken = document.querySelector('meta[name="csrf-token"]').content
      
      fetch(`/habits/${habitId}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          habit: {
            position: newPosition
          }
        })
      }).then(response => {
        if (!response.ok) {
          console.error(`Failed to update habit ${habitId} position:`, response.statusText)
        }
      }).catch(error => {
        console.error(`Error updating habit ${habitId} position:`, error)
      })
    })
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
    
    // Store original values
    this.editingHabitId = habitId
    this.originalName = currentName
    
    // Replace span with input
    nameElement.style.display = "none"
    nameElement.parentElement.appendChild(input)
    
    // Focus and select text
    input.focus()
    input.select()
    
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