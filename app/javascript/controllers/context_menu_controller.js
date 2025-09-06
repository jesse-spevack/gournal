import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "backdrop", "habitItem"]
  
  static values = {
    selectedHabitId: Number,
    selectedHabitName: String
  }

  // Constants for better maintainability
  static CONSTANTS = {
    LONG_PRESS_DURATION: 500, // milliseconds
    MOVEMENT_THRESHOLD: 10, // pixels
    VIEWPORT_MARGIN: 10, // pixels for menu positioning
    EDGE_MARGIN: 20, // pixels from viewport edge
    HAPTIC_DURATION: 10 // milliseconds
  }

  connect() {
    this.longPressTimer = null
    this.longPressThreshold = this.constructor.CONSTANTS.LONG_PRESS_DURATION
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
    
    if (this.touchMovedTooMuch(event.touches[0])) {
      this.cancelLongPress()
    }
  }

  touchMovedTooMuch(touch) {
    const deltaX = Math.abs(touch.clientX - this.touchStartPosition.x)
    const deltaY = Math.abs(touch.clientY - this.touchStartPosition.y)
    const threshold = this.constructor.CONSTANTS.MOVEMENT_THRESHOLD
    
    return deltaX > threshold || deltaY > threshold
  }

  cancelLongPress() {
    this.clearLongPressTimer()
    this.touchStartPosition = null
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
    
    const habitItem = this.element.querySelector(`[data-habit-id="${this.selectedHabitIdValue}"]`)
    const habitNameElement = habitItem?.querySelector('.habit-name')
    
    if (!habitNameElement) return
    
    this.startInlineEdit(habitNameElement)
    this.hideMenu()
  }

  startInlineEdit(habitNameElement) {
    // Store original name for cancellation
    const originalName = habitNameElement.textContent.trim()
    this.originalHabitName = originalName
    this.editingElement = habitNameElement
    
    // Make element editable
    habitNameElement.contentEditable = true
    habitNameElement.classList.add('habit-name--editing')
    
    // Focus and select all text
    habitNameElement.focus()
    this.selectAllText(habitNameElement)
    
    // Add event listeners for save/cancel
    this.boundKeydownHandler = this.handleEditKeydown.bind(this)
    this.boundBlurHandler = this.handleEditBlur.bind(this)
    
    habitNameElement.addEventListener('keydown', this.boundKeydownHandler)
    habitNameElement.addEventListener('blur', this.boundBlurHandler)
  }

  selectAllText(element) {
    const range = document.createRange()
    range.selectNodeContents(element)
    const selection = window.getSelection()
    selection.removeAllRanges()
    selection.addRange(range)
  }

  handleEditKeydown(event) {
    if (event.key === 'Enter') {
      event.preventDefault()
      this.saveEdit()
    } else if (event.key === 'Escape') {
      event.preventDefault()
      this.cancelEdit()
    }
  }

  handleEditBlur() {
    // Save on blur (when user clicks away)
    this.saveEdit()
  }

  saveEdit() {
    if (!this.editingElement) return
    
    const newName = this.editingElement.textContent.trim()
    const originalName = this.originalHabitName
    
    if (newName && newName !== originalName) {
      this.updateHabitName(this.selectedHabitIdValue, newName)
    }
    
    this.finishEdit()
  }

  cancelEdit() {
    if (!this.editingElement) return
    
    // Restore original name
    this.editingElement.textContent = this.originalHabitName
    this.finishEdit()
  }

  finishEdit() {
    if (!this.editingElement) return
    
    // Remove editing state
    this.editingElement.contentEditable = false
    this.editingElement.classList.remove('habit-name--editing')
    this.editingElement.blur()
    
    // Remove event listeners
    this.editingElement.removeEventListener('keydown', this.boundKeydownHandler)
    this.editingElement.removeEventListener('blur', this.boundBlurHandler)
    
    // Clean up
    this.editingElement = null
    this.originalHabitName = null
    this.boundKeydownHandler = null
    this.boundBlurHandler = null
  }

  async updateHabitName(habitId, newName) {
    try {
      await this.sendHabitUpdateRequest(habitId, newName)
      this.updateHabitNameInDOM(habitId, newName)
    } catch (error) {
      this.handleUpdateError('update habit name', error)
    }
  }

  async sendHabitUpdateRequest(habitId, newName) {
    const response = await fetch(`/habits/${habitId}`, {
      method: 'PATCH',
      headers: this.buildRequestHeaders(),
      body: JSON.stringify({ habit: { name: newName } })
    })
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }
    
    return response
  }

  buildRequestHeaders() {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    
    return {
      'Content-Type': 'application/json',
      'X-CSRF-Token': csrfToken,
      'Accept': 'application/json'
    }
  }

  updateHabitNameInDOM(habitId, newName) {
    const habitItem = document.querySelector(`[data-habit-id="${habitId}"]`)
    if (!habitItem) return

    const nameElement = habitItem.querySelector('.habit-name')
    if (nameElement) {
      nameElement.textContent = newName
    }
    habitItem.dataset.habitName = newName
  }

  handleUpdateError(action, error) {
    console.error(`Failed to ${action}:`, error)
    alert(`Failed to ${action}. Please try again.`)
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
    
    if (!this.confirmDeletion()) {
      this.hideMenu()
      return
    }
    
    try {
      await this.sendDeleteRequest(this.selectedHabitIdValue)
      this.removeHabitFromDOM(this.selectedHabitIdValue)
    } catch (error) {
      this.handleUpdateError('delete habit', error)
    }
    
    this.hideMenu()
  }

  confirmDeletion() {
    const habitName = this.selectedHabitNameValue || "this habit"
    return confirm(`Delete "${habitName}"?`)
  }

  async sendDeleteRequest(habitId) {
    const response = await fetch(`/habits/${habitId}`, {
      method: 'DELETE',
      headers: this.buildDeleteHeaders()
    })
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }
    
    return response
  }

  buildDeleteHeaders() {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    
    return {
      'X-CSRF-Token': csrfToken,
      'Accept': 'application/json'
    }
  }

  removeHabitFromDOM(habitId) {
    const habitItem = document.querySelector(`[data-habit-id="${habitId}"]`)
    if (habitItem) {
      habitItem.remove()
    }
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