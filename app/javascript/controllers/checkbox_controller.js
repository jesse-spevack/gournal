import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="checkbox"
export default class extends Controller {
  static targets = [ "input", "xMark", "boxPath" ]

  connect() {
    // Set initial state based on checkbox checked status
    this.updateVisual()
  }

  toggle() {
    // Update visual when checkbox state changes
    this.updateVisual()
  }

  updateVisual() {
    if (this.hasInputTarget && this.hasXMarkTarget) {
      if (this.inputTarget.checked) {
        // Show X mark and update styling for checked state
        this.xMarkTarget.classList.add('show')
        if (this.hasBoxPathTarget) {
          this.boxPathTarget.style.stroke = 'var(--ink-hover)'
          this.boxPathTarget.style.strokeWidth = '1.6'
          this.boxPathTarget.style.opacity = '0.95'
        }
      } else {
        // Hide X mark and revert to unchecked styling
        this.xMarkTarget.classList.remove('show')
        if (this.hasBoxPathTarget) {
          this.boxPathTarget.style.stroke = 'var(--ink-primary)'
          this.boxPathTarget.style.strokeWidth = '1.4'
          this.boxPathTarget.style.opacity = '0.85'
        }
      }
    }
  }
}