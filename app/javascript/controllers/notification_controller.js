import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="notification"
export default class extends Controller {
  connect() {
    // Auto-dismiss after specified time (if data-auto-dismiss attribute is present)
    const autoDismiss = this.element.dataset.autoDismiss
    if (autoDismiss) {
      this.autoDismissTimeout = setTimeout(
        () => this.close(),
        parseInt(autoDismiss) || 5000
      )
    }
  }

  disconnect() {
    // Clear the auto-dismiss timeout if the element is removed before it fires
    if (this.autoDismissTimeout) {
      clearTimeout(this.autoDismissTimeout)
    }
  }

  close() {
    // Clear the timeout if closing manually
    if (this.autoDismissTimeout) {
      clearTimeout(this.autoDismissTimeout)
    }

    // Remove the notification element with a smooth transition
    this.element.style.opacity = "0"
    this.element.style.transition = "opacity 0.3s ease-out"

    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
