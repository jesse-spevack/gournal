import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    xMarks: Array
  }
  
  static targets = [
    "form",
    "slugDisplay",
    "slugField", 
    "urlDisplay",
    "habitsPublicField",
    "reflectionsPublicField",
    "submitButton",
    "option"
  ]

  connect() {
    this.markIndex = 0
    this.editingElement = null
    this.originalSlug = null
    
    // Initialize checkbox states based on current values
    this.initializeCheckboxStates()
  }
  
  initializeCheckboxStates() {
    // Set initial checkbox states based on field values
    this.updateCheckboxDisplay('habits_public', this.habitsPublicFieldTarget.value === 'true')
    this.updateCheckboxDisplay('reflections_public', this.reflectionsPublicFieldTarget.value === 'true')
  }

  toggleOption(event) {
    event.preventDefault()
    event.stopPropagation()
    
    const clickedElement = event.currentTarget
    const option = clickedElement.dataset.option
    const fieldTarget = option === 'habits_public' ? this.habitsPublicFieldTarget : this.reflectionsPublicFieldTarget
    
    // Toggle the value
    const currentValue = fieldTarget.value === 'true'
    const newValue = !currentValue
    
    // Update the field and display
    fieldTarget.value = newValue
    this.updateCheckboxDisplay(option, newValue)
  }
  
  updateCheckboxDisplay(option, isChecked) {
    const checkboxContainer = this.getCheckboxContainerForOption(option)
    if (!checkboxContainer) return
    
    if (isChecked) {
      // Get next X mark variant from the randomized array
      const xVariant = this.xMarksValue[this.markIndex]
      this.markIndex = (this.markIndex + 1) % this.xMarksValue.length
      
      // Hide all X marks first
      checkboxContainer.querySelectorAll('.checkbox-x-wrapper').forEach(wrapper => {
        wrapper.style.display = 'none'
      })
      
      // Show the selected X mark variant
      const selectedWrapper = checkboxContainer.querySelector(`[data-x-variant="${xVariant}"]`)
      if (selectedWrapper) {
        selectedWrapper.style.display = 'block'
      }
    } else {
      // Hide all X marks
      checkboxContainer.querySelectorAll('.checkbox-x-wrapper').forEach(wrapper => {
        wrapper.style.display = 'none'
      })
    }
  }
  
  getCheckboxContainerForOption(option) {
    // Find the option target that matches this option field
    const optionElement = this.optionTargets.find(target => 
      target.dataset.optionField === option
    )
    
    if (optionElement) {
      return optionElement.querySelector('.checkbox-container')
    }
    
    return null
  }

  // Slug editing functionality
  editSlug(event) {
    event.preventDefault()
    event.stopPropagation()
    
    if (this.editingElement) return // Already editing
    
    const slugElement = this.slugDisplayTarget
    this.startInlineEdit(slugElement)
  }
  
  startInlineEdit(slugElement) {
    // Store editing state
    this.originalSlug = slugElement.textContent.trim()
    this.editingElement = slugElement
    
    // Check if it's showing placeholder text
    const isPlaceholder = slugElement.dataset.placeholder === "true"
    const currentText = isPlaceholder ? "" : this.originalSlug
    
    // Create input element
    const input = document.createElement("input")
    input.type = "text"
    input.value = currentText
    input.className = "habit-input habit-input--editing"
    input.placeholder = "your-custom-share-link"
    
    // Replace element content with input
    slugElement.innerHTML = ""
    slugElement.appendChild(input)
    
    // Focus and select text
    input.focus()
    if (currentText) {
      input.select()
    }
    
    // Add event listeners
    input.addEventListener("blur", () => this.finishEdit())
    input.addEventListener("keydown", (e) => {
      if (e.key === "Enter") {
        e.preventDefault()
        this.finishEdit()
      } else if (e.key === "Escape") {
        this.cancelEdit()
      }
    })
  }
  
  finishEdit() {
    if (!this.editingElement) return
    
    const input = this.editingElement.querySelector("input")
    if (!input) return
    
    const newSlug = input.value.trim()
    const isValid = this.validateSlug(newSlug)
    
    if (isValid) {
      // Update the slug field
      this.slugFieldTarget.value = newSlug
      
      // Update display
      this.editingElement.textContent = newSlug || "your-custom-share-link"
      this.editingElement.dataset.placeholder = newSlug ? "false" : "true"
      
      // Auto-submit the form to save the slug
      this.formTarget.requestSubmit()
    } else {
      // Invalid slug, revert to original
      this.cancelEdit()
    }
    
    this.editingElement = null
    this.originalSlug = null
  }
  
  cancelEdit() {
    if (!this.editingElement) return
    
    // Restore original text
    const displayText = this.originalSlug || "your-custom-share-link"
    this.editingElement.textContent = displayText
    this.editingElement.dataset.placeholder = this.originalSlug ? "false" : "true"
    
    this.editingElement = null
    this.originalSlug = null
  }
  
  validateSlug(slug) {
    // Allow empty (will be handled as null)
    if (!slug) return true
    
    // Check format: lowercase letters, numbers, underscores, and dashes only
    const slugPattern = /^[a-z0-9_-]+$/
    
    // Check length: 3-30 characters
    return slug.length >= 3 && slug.length <= 30 && slugPattern.test(slug)
  }

  // URL copying functionality
  copyUrl(event) {
    event.preventDefault()
    
    // Don't copy if clicking on the editable slug part
    if (event.target.closest('.profile-slug-editable')) {
      return
    }
    
    const slug = this.slugFieldTarget.value
    if (!slug) {
      // No slug set, can't copy
      return
    }
    
    const fullUrl = `https://verynormal.dev/${slug}`
    
    // Copy to clipboard
    navigator.clipboard.writeText(fullUrl).then(() => {
      // Show feedback - temporarily change the copy icon
      this.showCopyFeedback()
    }).catch(() => {
      // Fallback for older browsers
      this.fallbackCopy(fullUrl)
    })
  }
  
  showCopyFeedback() {
    const urlDisplay = this.urlDisplayTarget
    
    // Temporarily add copied class for styling
    urlDisplay.classList.add('url-copied')
    
    // Remove after 2 seconds
    setTimeout(() => {
      urlDisplay.classList.remove('url-copied')
    }, 2000)
  }
  
  fallbackCopy(text) {
    // Create temporary text area for copying
    const textArea = document.createElement('textarea')
    textArea.value = text
    document.body.appendChild(textArea)
    textArea.select()
    document.execCommand('copy')
    document.body.removeChild(textArea)
    
    this.showCopyFeedback()
  }
}