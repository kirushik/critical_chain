import { Controller } from "@hotwired/stimulus";

// Simplified Stimulus controller for inline editing - just toggles CSS classes
export default class extends Controller {
  static targets = ["field", "display", "form", "input"];

  connect() {
    this.isSubmitting = false;
  }

  edit(event) {
    event.preventDefault();
    // Store the original value for comparison on blur
    this.originalValue = this.inputTarget.value;
    // Add editing class to show form, hide display
    this.fieldTarget.classList.add("editing");
    // Focus and select the input
    this.inputTarget.focus();
    this.inputTarget.select();
  }

  cancel(event) {
    if (event) event.preventDefault();
    // Reset the input to original value
    if (this.originalValue !== undefined) {
      this.inputTarget.value = this.originalValue;
    }
    // Remove editing class to show display, hide form
    this.fieldTarget.classList.remove("editing");
    this.isSubmitting = false;
  }

  handleBlur(event) {
    // Don't auto-cancel if we're submitting (clicking Save button)
    if (this.isSubmitting) {
      return;
    }

    // Only auto-cancel if value hasn't changed
    if (this.originalValue === this.inputTarget.value) {
      this.cancel();
    }
  }

  handleSubmit(event) {
    // Set flag to prevent blur from canceling during save
    this.isSubmitting = true;
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      event.preventDefault();
      this.cancel();
    }
    // Enter key naturally submits the form (handled by Turbo)
  }
}
