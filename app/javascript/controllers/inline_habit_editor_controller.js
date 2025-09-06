import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["name", "newInput", "newForm"]

  connect() {
    this.editingHabitId = null
    this.originalName = null
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

  async createHabit(event) {
    const input = this.newInputTarget
    const habitName = input.value.trim()
    
    // If called from blur event, check if there's a habit name to create
    if (event.type === 'blur') {
      if (habitName) {
        // Use AJAX to create habit without page reload
        await this.createHabitViaAjax(habitName, input)
      }
      // Don't prevent default for blur events
      return
    }
    
    // For form submission events, validate input and use AJAX
    if (!habitName) {
      event.preventDefault()
      return
    }
    
    event.preventDefault()
    await this.createHabitViaAjax(habitName, input)
  }

  async createHabitViaAjax(habitName, input) {
    const form = this.newFormTarget
    const formData = new FormData(form)
    formData.set('name', habitName)
    
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    
    try {
      const response = await fetch(form.action, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': csrfToken,
          'Accept': 'application/json'
        },
        body: formData
      })
      
      if (response.ok) {
        // Clear the input on successful creation
        input.value = ''
        
        // Reload the page to show the new habit
        // This maintains the current UX while fixing the disappearing issue
        window.location.reload()
      } else {
        console.error('Failed to create habit:', response.statusText)
        // Keep the input value so user can try again
      }
    } catch (error) {
      console.error('Error creating habit:', error)
      // Keep the input value so user can try again
    }
  }

  cancelNew() {
    if (this.hasNewInputTarget) {
      this.newInputTarget.value = ""
    }
  }
}