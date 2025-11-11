import { Controller } from "@hotwired/stimulus";

// Stimulus controller for inline editing using Turbo Streams
export default class extends Controller {
  static targets = ["field", "display"];
  static values = {
    url: String,
    name: String,
    type: { type: String, default: "text" },
    pk: Number,
    model: String,
  };

  connect() {
    this.editing = false;
    this.originalValue = null;
  }

  edit(event) {
    event.preventDefault();
    if (this.editing) return;

    this.editing = true;
    const value = this.displayTarget.textContent.trim();
    this.originalValue = value;

    // Create editable-inline container
    const container = document.createElement("span");
    container.className = "editable-inline";

    // Create HTML form for Turbo
    const form = document.createElement("form");
    form.method = "post";
    form.action = this.urlValue;
    form.setAttribute("data-turbo", "true");
    form.setAttribute("data-turbo-stream", "true");

    // Add hidden method field for PATCH
    const methodField = document.createElement("input");
    methodField.type = "hidden";
    methodField.name = "_method";
    methodField.value = "patch";
    form.appendChild(methodField);

    // Add CSRF token
    const csrfField = document.createElement("input");
    csrfField.type = "hidden";
    csrfField.name = "authenticity_token";
    csrfField.value = this.csrfToken();
    form.appendChild(csrfField);

    // Create input wrapper
    const inputWrapper = document.createElement("div");
    inputWrapper.className = "editable-input";

    // Create input element
    const input = document.createElement("input");
    input.type = this.typeValue === "number" ? "number" : "text";
    input.value = value;
    input.name = `${this.modelValue}[${this.nameValue}]`;
    input.className = "form-control input-sm";
    input.style.width = this.typeValue === "number" ? "100px" : "200px";

    inputWrapper.appendChild(input);
    form.appendChild(inputWrapper);

    // Create buttons container
    const buttons = document.createElement("div");
    buttons.className = "editable-button-group";

    // Create save button
    const saveButton = document.createElement("button");
    saveButton.type = "submit";
    saveButton.className = "btn btn-sm btn-success editable-submit";
    saveButton.innerHTML = '<i class="fa fa-check"></i>';

    // Create cancel button
    const cancelButton = document.createElement("button");
    cancelButton.type = "button";
    cancelButton.className = "btn btn-sm btn-default editable-cancel";
    cancelButton.innerHTML = '<i class="fa fa-times"></i>';
    cancelButton.addEventListener("click", (e) => {
      e.preventDefault();
      this.cancel();
    });

    buttons.appendChild(saveButton);
    buttons.appendChild(cancelButton);
    form.appendChild(buttons);

    container.appendChild(form);

    // Replace display with container
    this.displayTarget.style.display = "none";
    this.displayTarget.insertAdjacentElement("afterend", container);

    this.inputElement = input;
    this.containerElement = container;
    this.formElement = form;
    input.focus();
    input.select();

    // Handle Enter and Escape keys
    input.addEventListener("keydown", (e) => {
      if (e.key === "Escape") {
        e.preventDefault();
        this.cancel();
      }
      // Enter will naturally submit the form
    });

    // Handle blur - close if value unchanged
    input.addEventListener("blur", (e) => {
      // Small delay to allow button clicks to register
      setTimeout(() => {
        if (this.editing && input.value === this.originalValue) {
          this.cancel();
        }
      }, 200);
    });

    // Listen for turbo:submit-end to close the editor after successful submission
    form.addEventListener("turbo:submit-end", (e) => {
      if (e.detail.success) {
        this.cleanup();
      }
    });
  }

  cancel() {
    this.cleanup();
  }

  cleanup() {
    if (this.containerElement) {
      this.containerElement.remove();
      this.containerElement = null;
    }
    this.inputElement = null;
    this.formElement = null;
    this.displayTarget.style.display = "";
    this.editing = false;
    this.originalValue = null;
  }

  csrfToken() {
    const meta = document.querySelector('meta[name="csrf-token"]');
    return meta ? meta.content : "";
  }
}
