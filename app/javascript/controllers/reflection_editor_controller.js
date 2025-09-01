import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="reflection-editor"
export default class extends Controller {
  static values = { 
    id: String,
    date: String, 
    userId: String 
  }

  connect() {
    this.debounceTimer = null
    this.element.addEventListener('input', this.debouncedSave.bind(this))
  }

  disconnect() {
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }
  }

  autoResize() {
    // Auto-resize textarea based on content
    this.element.style.height = 'auto'
    this.element.style.height = this.element.scrollHeight + 'px'
  }

  onFocus() {
    // Expand textarea when focused (remove truncation)
    this.element.classList.add('focused')
    this.autoResize()
  }

  onBlur() {
    // Apply truncation when unfocused
    this.element.classList.remove('focused')
    this.element.style.height = 'auto'
  }

  debouncedSave() {
    // Clear existing timer
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }

    // Set new timer for 500ms delay
    this.debounceTimer = setTimeout(() => {
      this.saveReflection()
    }, 500)
  }

  async saveReflection() {
    const content = this.element.value
    const csrfToken = this.getCsrfToken()

    try {
      let response
      const reflectionData = {
        daily_reflection: {
          content: content,
          date: this.dateValue
        }
      }

      if (this.idValue) {
        // Update existing reflection
        response = await fetch(`/habit_entries/1/daily_reflections/${this.idValue}`, {
          method: 'PATCH',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': csrfToken
          },
          body: JSON.stringify(reflectionData)
        })
      } else {
        // Create new reflection
        response = await fetch('/habit_entries/1/daily_reflections', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': csrfToken
          },
          body: JSON.stringify(reflectionData)
        })
      }

      if (response.ok) {
        const data = await response.json()
        if (data.status === 'success' && data.id && !this.idValue) {
          // Update the id value for future updates
          this.idValue = data.id
        }
        this.showSaveIndicator('success')
      } else {
        this.showSaveIndicator('error')
        console.error('Failed to save reflection:', response.statusText)
      }
    } catch (error) {
      this.showSaveIndicator('error')
      console.error('Error saving reflection:', error)
    }
  }

  getCsrfToken() {
    // Try to get CSRF token from meta tag first, then from data attribute
    const metaTag = document.querySelector('meta[name="csrf-token"]')
    if (metaTag) {
      return metaTag.getAttribute('content')
    }
    
    const gridElement = document.querySelector('[data-csrf-token]')
    if (gridElement) {
      return gridElement.getAttribute('data-csrf-token')
    }
    
    return null
  }

  showSaveIndicator(status) {
    // Visual feedback for save status (could be enhanced with CSS classes)
    this.element.classList.remove('saving-success', 'saving-error')
    this.element.classList.add(`saving-${status}`)
    
    setTimeout(() => {
      this.element.classList.remove(`saving-${status}`)
    }, 2000)
  }
}