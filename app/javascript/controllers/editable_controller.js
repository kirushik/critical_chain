import { Controller } from "@hotwired/stimulus";

// Simplified Stimulus controller for inline editing - just toggles CSS classes
export default class extends Controller {
  static targets = ["field", "display", "form", "input"];

  edit(event) {
    event.preventDefault();
    // Add editing class to show form, hide display
    this.fieldTarget.classList.add("editing");
    // Focus and select the input
    this.inputTarget.focus();
    this.inputTarget.select();
  }

  cancel(event) {
    if (event) event.preventDefault();
    // Remove editing class to show display, hide form
    this.fieldTarget.classList.remove("editing");
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      event.preventDefault();
      this.cancel();
    }
    // Enter key naturally submits the form (handled by Turbo)
  }
}
