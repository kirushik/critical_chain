import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="notification"
export default class extends Controller {
  connect() {
    // console.log("Notification controller connected")
  }

  close() {
    // Remove the notification element with a smooth transition
    this.element.style.opacity = "0"
    this.element.style.transition = "opacity 0.3s ease-out"

    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
