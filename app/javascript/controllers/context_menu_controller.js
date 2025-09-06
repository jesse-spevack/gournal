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
    
    // Reset desktop positioning
    const menu = this.menuTarget
    menu.style.left = ""
    menu.style.top = ""
  }

  isDesktop() {
    return window.matchMedia("(hover: hover) and (pointer: fine)").matches
  }

  // Menu action methods
  editName() {
    if (!this.selectedHabitIdValue) return
    
    // Find the habit name element and trigger inline edit
    const habitItem = document.querySelector(`[data-habit-id="${this.selectedHabitIdValue}"]`)
    if (habitItem) {
      const nameElement = habitItem.querySelector('[data-inline-habit-editor-target="name"]')
      if (nameElement) {
        nameElement.click()
      }
    }
    
    this.hideMenu()
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