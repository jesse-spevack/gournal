import { Controller } from "@hotwired/stimulus"

// Handles the Add Habit form interactions
export default class extends Controller {
  static targets = ["nameInput", "submitButton"]
  
  connect() {
    // Focus on the input field when the controller connects
    if (this.hasNameInputTarget) {
      this.nameInputTarget.focus()
    }
  }
  
  // Clear the form after successful submission (called by Turbo)
  reset() {
    this.element.reset()
    if (this.hasNameInputTarget) {
      this.nameInputTarget.focus()
    }
  }
  
  // Handle form submission
  submit(event) {
    // Disable the submit button to prevent double submissions
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.textContent = "Adding..."
    }
  }
}