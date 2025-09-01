import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="checkbox"
export default class extends Controller {
  static targets = [ "input", "xMark", "boxPath" ]
  static classes = [ "checked", "unchecked", "xVisible" ]

  connect() {
    // Set initial state based on checkbox checked status
    this.updateVisual()
  }

  toggle() {
    // Update visual when checkbox state changes
    this.updateVisual()
    
    // Submit the form
    this.submitForm()
  }

  submitForm() {
    // Find the closest form element and submit it
    const form = this.inputTarget.closest('form')
    if (form) {
      form.requestSubmit()
    }
  }

  updateVisual() {
    if (this.hasInputTarget && this.hasXMarkTarget) {
      if (this.inputTarget.checked) {
        // Apply checked state classes
        if (this.hasXVisibleClass) {
          this.xMarkTarget.classList.add(...this.xVisibleClasses)
        }
        if (this.hasBoxPathTarget) {
          if (this.hasCheckedClass) {
            this.boxPathTarget.classList.add(...this.checkedClasses)
          }
          if (this.hasUncheckedClass) {
            this.boxPathTarget.classList.remove(...this.uncheckedClasses)
          }
        }
      } else {
        // Apply unchecked state classes
        if (this.hasXVisibleClass) {
          this.xMarkTarget.classList.remove(...this.xVisibleClasses)
        }
        if (this.hasBoxPathTarget) {
          if (this.hasCheckedClass) {
            this.boxPathTarget.classList.remove(...this.checkedClasses)
          }
          if (this.hasUncheckedClass) {
            this.boxPathTarget.classList.add(...this.uncheckedClasses)
          }
        }
      }
    }
  }
}