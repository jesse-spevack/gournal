import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    xMarks: Array,
    targetYear: Number,
    targetMonth: Number
  }
  
  static targets = [
    "form",
    "strategyField",
    "submitButton",
    "copyCheckbox",
    "freshCheckbox"
  ]

  connect() {
    this.currentSelection = null
    this.markIndex = 0
  }

  selectOption(event) {
    event.preventDefault()
    event.stopPropagation()
    
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
    // Get the checkbox container for this option
    const checkboxContainer = option === 'copy' ? this.copyCheckboxTarget : this.freshCheckboxTarget
    
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
  }

  uncheckOption(option) {
    // Get the checkbox container for this option
    const checkboxContainer = option === 'copy' ? this.copyCheckboxTarget : this.freshCheckboxTarget
    
    // Hide all X marks
    checkboxContainer.querySelectorAll('.checkbox-x-wrapper').forEach(wrapper => {
      wrapper.style.display = 'none'
    })
  }

  getCheckboxContainer(option) {
    return this.element.querySelector(`[data-option="${option}"]`)
  }

  handleSubmit(event) {
    if (!this.currentSelection) {
      event.preventDefault()
      return
    }
    
    // Set the strategy value in the form
    this.strategyFieldTarget.value = this.currentSelection
  }
}