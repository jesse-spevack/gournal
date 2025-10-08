import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="timezone"
export default class extends Controller {
  connect() {
    this.detectAndStoreTimezone()
  }

  detectAndStoreTimezone() {
    const timezone = Intl.DateTimeFormat().resolvedOptions().timeZone

    sessionStorage.setItem('userTimezone', timezone)

    const sentTimezone = sessionStorage.getItem('sentTimezone')
    if (timezone !== sentTimezone) {
      this.sendTimezoneToServer(timezone)
    }
  }

  sendTimezoneToServer(timezone) {
    fetch('/timezone', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({ timezone: timezone })
    }).then(() => {
      sessionStorage.setItem('sentTimezone', timezone)
    })
  }
}
