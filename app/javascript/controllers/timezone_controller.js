import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="timezone"
export default class extends Controller {
  connect() {
    this.detectAndStoreTimezone()
  }

  detectAndStoreTimezone() {
    const timezone = Intl.DateTimeFormat().resolvedOptions().timeZone

    const sentTimezone = sessionStorage.getItem('sentTimezone')
    if (timezone !== sentTimezone) {
      // Mark as "sending" immediately to prevent duplicate sends
      sessionStorage.setItem('sentTimezone', timezone)
      this.sendTimezoneToServer(timezone)
    }
  }

  sendTimezoneToServer(timezone) {
    const csrfToken = document.querySelector('[name="csrf-token"]')?.content
    if (!csrfToken) {
      console.warn('CSRF token not found, cannot set timezone')
      return
    }

    fetch('/timezone', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify({ timezone: timezone })
    })
    .then(response => {
      if (!response.ok) {
        console.warn('Failed to set timezone:', response.status)
        sessionStorage.removeItem('sentTimezone')
      }
    })
    .catch(error => {
      console.warn('Network error setting timezone:', error)
      sessionStorage.removeItem('sentTimezone')
    })
  }
}
