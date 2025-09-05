import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    xMarks: Array,
    targetYear: Number,
    targetMonth: Number
  }
  
  static targets = [
    "form",
    "copyStrategy", 
    "freshStrategy",
    "submitButton"
  ]

  connect() {
    this.currentSelection = null
    this.markIndex = 0
  }

  selectOption(event) {
    event.preventDefault()
    
    const option = event.currentTarget.dataset.option
    const isCurrentlySelected = this.currentSelection === option
    
    if (isCurrentlySelected) {
      // Uncheck current selection
      this.uncheckOption(option)
      this.currentSelection = null
      this.submitButtonTarget.disabled = true
    } else {
      // Uncheck any previous selection
      if (this.currentSelection) {
        this.uncheckOption(this.currentSelection)
      }
      
      // Check new selection
      this.checkOption(option)
      this.currentSelection = option
      this.submitButtonTarget.disabled = false
    }
  }

  checkOption(option) {
    const container = this.getCheckboxContainer(option)
    const checkboxContainer = container.querySelector('.checkbox-container')
    
    // Get next X mark variant
    const xVariant = this.xMarksValue[this.markIndex]
    this.markIndex = (this.markIndex + 1) % this.xMarksValue.length
    
    // Add X mark to checkbox
    if (!checkboxContainer.querySelector('.x-mark')) {
      const xMark = document.createElement('div')
      xMark.className = 'x-mark'
      xMark.innerHTML = `<svg class="x-mark-${xVariant}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <line x1="18" y1="6" x2="6" y2="18"></line>
        <line x1="6" y1="6" x2="18" y2="18"></line>
      </svg>`
      checkboxContainer.appendChild(xMark)
    }
  }

  uncheckOption(option) {
    const container = this.getCheckboxContainer(option)
    const xMark = container.querySelector('.x-mark')
    if (xMark) {
      xMark.remove()
    }
  }

  getCheckboxContainer(option) {
    return this.element.querySelector(`[data-option="${option}"]`).closest('.month-setup-option')
  }

  handleSubmit(event) {
    if (!this.currentSelection) {
      event.preventDefault()
      return
    }
    
    // Set the strategy value in the form
    if (this.currentSelection === "copy") {
      this.copyStrategyTarget.disabled = false
      this.freshStrategyTarget.disabled = true
    } else {
      this.freshStrategyTarget.disabled = false
      this.copyStrategyTarget.disabled = true
    }
  }
}