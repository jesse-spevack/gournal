import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "backdrop", "habitItem"]
  
  static values = {
    selectedHabitId: Number,
    selectedHabitName: String
  }

  connect() {
    this.longPressTimer = null
    this.longPressThreshold = 500 // milliseconds
    this.touchStartPosition = null
    this.menuVisible = false
    
    // Bind touch events to habit items
    this.bindTouchEvents()
    
    // Bind right-click event for desktop
    this.bindContextMenuEvents()
  }

  disconnect() {
    this.clearLongPressTimer()
  }

  clearLongPressTimer() {
    if (this.longPressTimer) {
      clearTimeout(this.longPressTimer)
      this.longPressTimer = null
    }
  }

  showMenu() {
    if (this.hasMenuTarget && this.hasBackdropTarget) {
      this.menuTarget.classList.add("context-menu--visible")
      this.backdropTarget.classList.add("context-menu-backdrop--visible")
      this.menuVisible = true
      
      // Add event listener for escape key
      this.escapeHandler = (event) => {
        if (event.key === "Escape") {
          this.hideMenu()
        }
      }
      document.addEventListener("keydown", this.escapeHandler)
    }
  }

  hideMenu() {
    if (this.hasMenuTarget && this.hasBackdropTarget) {
      this.menuTarget.classList.remove("context-menu--visible")
      this.backdropTarget.classList.remove("context-menu-backdrop--visible")
      this.menuVisible = false
      
      // Remove escape key listener
      if (this.escapeHandler) {
        document.removeEventListener("keydown", this.escapeHandler)
        this.escapeHandler = null
      }
      
      // Clear selected habit
      this.selectedHabitIdValue = null
      this.selectedHabitNameValue = null
    }
  }

  positionMenuForDesktop(x, y) {
    if (!this.hasMenuTarget) return
    
    const menu = this.menuTarget
    const menuRect = menu.getBoundingClientRect()
    const viewportWidth = window.innerWidth
    const viewportHeight = window.innerHeight
    
    // Position near cursor with boundary detection
    let left = x
    let top = y
    
    // Flip horizontally if too close to right edge
    if (x + menuRect.width > viewportWidth - 20) {
      left = x - menuRect.width
    }
    
    // Flip vertically if too close to bottom edge
    if (y + menuRect.height > viewportHeight - 20) {
      top = y - menuRect.height
    }
    
    // Ensure menu stays within viewport
    left = Math.max(10, Math.min(left, viewportWidth - menuRect.width - 10))
    top = Math.max(10, Math.min(top, viewportHeight - menuRect.height - 10))
    
    menu.style.left = `${left}px`
    menu.style.top = `${top}px`
  }

  positionMenuForMobile() {
    if (!this.hasMenuTarget) return
    
    // Reset any desktop positioning - mobile uses CSS bottom sheet
    const menu = this.menuTarget
    menu.style.left = ""
    menu.style.top = ""
    menu.style.right = ""
    menu.style.bottom = ""
  }

  isDesktop() {
    return window.matchMedia("(hover: hover) and (pointer: fine)").matches
  }

  // Touch event handling for mobile
  bindTouchEvents() {
    if (!this.hasHabitItemTarget) return
    
    this.habitItemTargets.forEach(item => {
      // Touch events for long-press detection
      item.addEventListener('touchstart', this.handleTouchStart.bind(this), { passive: false })
      item.addEventListener('touchmove', this.handleTouchMove.bind(this), { passive: false })
      item.addEventListener('touchend', this.handleTouchEnd.bind(this), { passive: false })
      item.addEventListener('touchcancel', this.handleTouchCancel.bind(this), { passive: false })
    })
  }

  handleTouchStart(event) {
    // No conflicts to worry about now that inline editing is removed
    
    const habitItem = event.currentTarget
    const habitId = parseInt(habitItem.dataset.habitId)
    const habitName = habitItem.dataset.habitName
    
    // Store touch position to detect movement
    this.touchStartPosition = {
      x: event.touches[0].clientX,
      y: event.touches[0].clientY
    }
    
    // Start long press timer
    this.longPressTimer = setTimeout(() => {
      // Trigger haptic feedback if available
      if (navigator.vibrate) {
        navigator.vibrate(10)
      }
      
      // Set selected habit
      this.selectedHabitIdValue = habitId
      this.selectedHabitNameValue = habitName
      
      // Position and show menu for mobile
      this.positionMenuForMobile()
      this.showMenu()
      
      // Clear the timer
      this.longPressTimer = null
    }, this.longPressThreshold)
  }

  handleTouchMove(event) {
    if (!this.longPressTimer || !this.touchStartPosition) return
    
    // Calculate movement distance
    const moveThreshold = 10 // pixels
    const deltaX = Math.abs(event.touches[0].clientX - this.touchStartPosition.x)
    const deltaY = Math.abs(event.touches[0].clientY - this.touchStartPosition.y)
    
    // Cancel long press if user moved finger too much
    if (deltaX > moveThreshold || deltaY > moveThreshold) {
      this.clearLongPressTimer()
      this.touchStartPosition = null
    }
  }

  handleTouchEnd(event) {
    this.clearLongPressTimer()
    this.touchStartPosition = null
  }

  handleTouchCancel(event) {
    this.clearLongPressTimer()
    this.touchStartPosition = null
  }

  // Right-click handling for desktop
  bindContextMenuEvents() {
    if (!this.hasHabitItemTarget) return
    
    this.habitItemTargets.forEach(item => {
      item.addEventListener('contextmenu', this.handleContextMenu.bind(this))
    })
  }

  handleContextMenu(event) {
    // Prevent default browser context menu
    event.preventDefault()
    
    const habitItem = event.currentTarget
    const habitId = parseInt(habitItem.dataset.habitId)
    const habitName = habitItem.dataset.habitName
    
    // Set selected habit
    this.selectedHabitIdValue = habitId
    this.selectedHabitNameValue = habitName
    
    // Position menu near cursor for desktop
    this.positionMenuForDesktop(event.clientX, event.clientY)
    this.showMenu()
  }

  // Menu action methods
  editName() {
    if (!this.selectedHabitIdValue) return
    
    // Use a simple prompt for now - in a real app you might want a modal
    const currentName = this.selectedHabitNameValue || ""
    const newName = prompt("Edit habit name:", currentName)
    
    if (newName && newName.trim() !== "" && newName.trim() !== currentName) {
      this.updateHabitName(this.selectedHabitIdValue, newName.trim())
    }
    
    this.hideMenu()
  }

  async updateHabitName(habitId, newName) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    
    try {
      const response = await fetch(`/habits/${habitId}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          habit: { name: newName }
        })
      })
      
      if (response.ok) {
        // Update the DOM
        const habitItem = document.querySelector(`[data-habit-id="${habitId}"]`)
        if (habitItem) {
          const nameElement = habitItem.querySelector('.habit-name')
          if (nameElement) {
            nameElement.textContent = newName
          }
          // Update the data attribute too
          habitItem.dataset.habitName = newName
        }
      } else {
        console.error('Failed to update habit name:', response.statusText)
        alert('Failed to update habit name. Please try again.')
      }
    } catch (error) {
      console.error('Error updating habit name:', error)
      alert('Failed to update habit name. Please try again.')
    }
  }

  moveUp() {
    if (!this.selectedHabitIdValue) return
    
    const habitItems = Array.from(this.element.querySelectorAll('.habit-item:not(.habit-item--new)'))
    const currentIndex = habitItems.findIndex(item => 
      parseInt(item.dataset.habitId) === this.selectedHabitIdValue
    )
    
    if (currentIndex > 0) {
      // Swap with previous item
      const currentItem = habitItems[currentIndex]
      const previousItem = habitItems[currentIndex - 1]
      previousItem.parentNode.insertBefore(currentItem, previousItem)
      
      // Update positions on server
      this.updatePositions()
    }
    
    this.hideMenu()
  }

  moveDown() {
    if (!this.selectedHabitIdValue) return
    
    const habitItems = Array.from(this.element.querySelectorAll('.habit-item:not(.habit-item--new)'))
    const currentIndex = habitItems.findIndex(item => 
      parseInt(item.dataset.habitId) === this.selectedHabitIdValue
    )
    
    if (currentIndex < habitItems.length - 1 && currentIndex >= 0) {
      // Swap with next item
      const currentItem = habitItems[currentIndex]
      const nextItem = habitItems[currentIndex + 1]
      nextItem.parentNode.insertBefore(nextItem, currentItem)
      
      // Update positions on server
      this.updatePositions()
    }
    
    this.hideMenu()
  }

  async deleteHabit() {
    if (!this.selectedHabitIdValue) return
    
    const habitName = this.selectedHabitNameValue || "this habit"
    
    // Simple confirmation - in production you might want a better UX
    if (!confirm(`Delete "${habitName}"?`)) {
      this.hideMenu()
      return
    }
    
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    
    try {
      const response = await fetch(`/habits/${this.selectedHabitIdValue}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': csrfToken,
          'Accept': 'application/json'
        }
      })
      
      if (response.ok) {
        // Remove the habit item from the DOM
        const habitItem = document.querySelector(`[data-habit-id="${this.selectedHabitIdValue}"]`)
        if (habitItem) {
          habitItem.remove()
        }
      } else {
        console.error('Failed to delete habit:', response.statusText)
      }
    } catch (error) {
      console.error('Error deleting habit:', error)
    }
    
    this.hideMenu()
  }

  async updatePositions() {
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
        keepalive: true
      })
      
      if (!response.ok) {
        console.error('Failed to update habit positions:', response.statusText)
      }
    } catch (error) {
      console.error('Error updating habit positions:', error)
    }
  }
}