import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="navbar"
export default class extends Controller {
  static targets = ["burger", "menu"]

  connect() {
    // console.log("Navbar controller connected")
  }

  toggle() {
    // Toggle the "is-active" class on both the navbar-burger and navbar-menu
    this.burgerTarget.classList.toggle("is-active")
    this.menuTarget.classList.toggle("is-active")
  }
}
