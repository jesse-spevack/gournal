import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    xMarks: Array,
    targetYear: Number,
    targetMonth: Number,
    defaultOption: String,
    fallbackOption: String
  }
  
  static targets = [
    "form",
    "strategyField",
    "submitButton",
    "option"
  ]

  connect() {
    this.currentSelection = null
    this.markIndex = 0
    
    // Use default option from data attribute or fall back to first option
    this.selectDefaultOption()
  }
  
  selectDefaultOption() {
    const defaultOption = this.hasDefaultOptionValue ? this.defaultOptionValue : this.getFirstOption()
    if (defaultOption) {
      this.currentSelection = defaultOption
      this.checkOption(defaultOption)
      this.submitButtonTarget.disabled = false
      this.strategyFieldTarget.value = defaultOption
    }
  }
  
  getFirstOption() {
    const firstOption = this.optionTargets[0]
    return firstOption ? firstOption.dataset.optionValue : null
  }
  
  getAllOptions() {
    return this.optionTargets.map(target => target.dataset.optionValue)
  }

  selectOption(event) {
    event.preventDefault()
    event.stopPropagation()
    
    const clickedElement = event.currentTarget
    const option = clickedElement.dataset.option || clickedElement.dataset.optionValue
    const isCurrentlySelected = this.currentSelection === option
    
    if (isCurrentlySelected) {
      // Uncheck current selection
      this.uncheckOption(option)
      this.currentSelection = null
      this.submitButtonTarget.disabled = true
      
      // Check for fallback behavior
      const fallbackOption = clickedElement.dataset.fallbackTo || this.getFallbackForOption(option)
      if (fallbackOption) {
        this.checkOption(fallbackOption)
        this.currentSelection = fallbackOption
        this.submitButtonTarget.disabled = false
        this.strategyFieldTarget.value = fallbackOption
      }
    } else {
      // Uncheck any previous selection
      if (this.currentSelection) {
        this.uncheckOption(this.currentSelection)
      }
      
      // Check new selection
      this.checkOption(option)
      this.currentSelection = option
      this.submitButtonTarget.disabled = false
      this.strategyFieldTarget.value = option
    }
  }
  
  getFallbackForOption(option) {
    // Use global fallback value if set, otherwise find next option
    if (this.hasFallbackOptionValue && option === this.defaultOptionValue) {
      return this.fallbackOptionValue
    }
    
    // Find next option in the list
    const options = this.getAllOptions()
    const currentIndex = options.indexOf(option)
    if (currentIndex >= 0 && options.length > 1) {
      return options[(currentIndex + 1) % options.length]
    }
    
    return null
  }

  checkOption(option) {
    const checkboxContainer = this.getCheckboxContainerForOption(option)
    if (!checkboxContainer) return
    
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
    const checkboxContainer = this.getCheckboxContainerForOption(option)
    if (!checkboxContainer) return
    
    // Hide all X marks
    checkboxContainer.querySelectorAll('.checkbox-x-wrapper').forEach(wrapper => {
      wrapper.style.display = 'none'
    })
  }
  
  getCheckboxContainerForOption(option) {
    // Find the option target that matches this option value
    const optionElement = this.optionTargets.find(target => 
      target.dataset.optionValue === option || target.dataset.option === option
    )
    
    if (optionElement) {
      // Find checkbox container within this option element
      return optionElement.querySelector('.checkbox-container')
    }
    
    // Fallback to data-option selector
    const element = this.element.querySelector(`[data-option="${option}"]`)
    return element ? element.querySelector('.checkbox-container') : null
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