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
    this.boundEventHandlers = []
    
    // Bind touch events to habit items
    this.bindTouchEvents()
    
    // Bind right-click event for desktop
    this.bindContextMenuEvents()
  }

  disconnect() {
    this.clearLongPressTimer()
    this.cleanupEventListeners()
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
      // Create bound handlers and store them for cleanup
      const handlers = {
        touchstart: this.handleTouchStart.bind(this),
        touchmove: this.handleTouchMove.bind(this),
        touchend: this.handleTouchEnd.bind(this),
        touchcancel: this.handleTouchCancel.bind(this)
      }
      
      // Bind touch events for long-press detection
      Object.entries(handlers).forEach(([event, handler]) => {
        item.addEventListener(event, handler, { passive: false })
      })
      
      // Store for cleanup
      this.boundEventHandlers.push({ item, handlers })
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
      try {
        if (navigator.vibrate) {
          navigator.vibrate(10)
        }
      } catch (error) {
        // Ignore vibration errors (browser security restrictions)
      }
      
      // Set selected habit (ensure ID is integer)
      this.selectedHabitIdValue = parseInt(habitId)
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
      const handler = this.handleContextMenu.bind(this)
      item.addEventListener('contextmenu', handler)
      
      // Store for cleanup
      this.boundEventHandlers.push({ 
        item, 
        handlers: { contextmenu: handler } 
      })
    })
  }

  cleanupEventListeners() {
    this.boundEventHandlers.forEach(({ item, handlers }) => {
      Object.entries(handlers).forEach(([event, handler]) => {
        item.removeEventListener(event, handler)
      })
    })
    this.boundEventHandlers = []
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
    
    // Position menu based on device type
    if (this.isDesktop()) {
      this.positionMenuForDesktop(event.clientX, event.clientY)
    } else {
      this.positionMenuForMobile()
    }
    this.showMenu()
  }

  // Menu action methods
  editName() {
    if (!this.selectedHabitIdValue) return
    
    const habitItem = this.element.querySelector(`[data-habit-id="${this.selectedHabitIdValue}"]`)
    const habitNameElement = habitItem?.querySelector('.habit-name')
    
    if (!habitNameElement || !habitItem) return
    
    // Store the habit ID from the DOM element to ensure it's correct
    const habitId = parseInt(habitItem.dataset.habitId)
    if (!habitId || isNaN(habitId)) return
    
    this.startInlineEdit(habitNameElement, habitId)
    this.hideMenu()
  }

  startInlineEdit(habitNameElement, habitId) {
    // Store editing state
    const originalName = habitNameElement.textContent.trim()
    this.originalHabitName = originalName
    this.editingElement = habitNameElement
    this.editingHabitId = habitId
    
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
    if (!this.editingElement || !this.editingHabitId) return
    
    const newName = this.editingElement.textContent.trim()
    const originalName = this.originalHabitName
    
    if (newName && newName !== originalName) {
      this.updateHabitName(this.editingHabitId, newName)
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
    
    // Store reference before cleanup to avoid race conditions
    const element = this.editingElement
    const keydownHandler = this.boundKeydownHandler
    const blurHandler = this.boundBlurHandler
    
    // Clean up state first to prevent re-entry
    this.editingElement = null
    this.originalHabitName = null
    this.editingHabitId = null
    this.boundKeydownHandler = null
    this.boundBlurHandler = null
    
    // Remove editing state from DOM
    element.contentEditable = false
    element.classList.remove('habit-name--editing')
    element.blur()
    
    // Remove event listeners
    if (keydownHandler) {
      element.removeEventListener('keydown', keydownHandler)
    }
    if (blurHandler) {
      element.removeEventListener('blur', blurHandler)
    }
  }

  async updateHabitName(habitId, newName) {
    const originalName = this.getHabitNameFromDOM(habitId)
    
    try {
      // Show loading state
      this.showLoadingState(habitId)
      await this.sendHabitUpdateRequest(habitId, newName)
      this.updateHabitNameInDOM(habitId, newName)
    } catch (error) {
      // Rollback on failure
      if (originalName) {
        this.updateHabitNameInDOM(habitId, originalName)
      }
      this.showErrorFeedback('Failed to update habit name')
      this.handleUpdateError('update habit name', error)
    } finally {
      this.hideLoadingState(habitId)
    }
  }

  async sendHabitUpdateRequest(habitId, newName) {
    return new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest()
      // Use absolute URL to avoid any base URL or routing issues
      const url = `${window.location.protocol}//${window.location.host}/habits/${habitId}`
      
      xhr.open('PATCH', url, true)
      xhr.setRequestHeader('Content-Type', 'application/json')
      
      // Safely get CSRF token with error handling
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
      if (!csrfToken) {
        reject(new Error('CSRF token not found'))
        return
      }
      xhr.setRequestHeader('X-CSRF-Token', csrfToken)
      xhr.setRequestHeader('Accept', 'application/json')
      
      xhr.onload = function() {
        if (xhr.status >= 200 && xhr.status < 300) {
          resolve(xhr)
        } else {
          reject(new Error(`HTTP ${xhr.status}: ${xhr.statusText}`))
        }
      }
      
      xhr.onerror = function() {
        reject(new Error('Network error'))
      }
      
      xhr.send(JSON.stringify({ habit: { name: newName } }))
    })
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
    // Silent failure - error is logged to console for debugging
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

  getHabitNameFromDOM(habitId) {
    const habitItem = this.element.querySelector(`[data-habit-id="${habitId}"]`)
    const nameElement = habitItem?.querySelector('.habit-name')
    return nameElement?.textContent?.trim()
  }

  showLoadingState(habitId) {
    const habitItem = this.element.querySelector(`[data-habit-id="${habitId}"]`)
    const nameElement = habitItem?.querySelector('.habit-name')
    if (nameElement) {
      nameElement.style.opacity = '0.5'
      nameElement.style.pointerEvents = 'none'
    }
  }

  hideLoadingState(habitId) {
    const habitItem = this.element.querySelector(`[data-habit-id="${habitId}"]`)
    const nameElement = habitItem?.querySelector('.habit-name')
    if (nameElement) {
      nameElement.style.opacity = ''
      nameElement.style.pointerEvents = ''
    }
  }

  showErrorFeedback(message) {
    // Simple error feedback - could be enhanced with toast notifications
    console.error(message)
    // Could add a temporary error indicator to the UI here
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