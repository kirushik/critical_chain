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

    // Create editable-inline container with unique ID
    const container = document.createElement("span");
    container.className = "editable-inline";
    container.id = `editable_inline_${this.modelValue}_${this.pkValue}_${this.nameValue}`;

    // Create HTML form for Turbo
    const form = document.createElement("form");
    form.method = "post";
    form.action = this.urlValue;
    form.setAttribute("data-turbo", "true");
    form.setAttribute("data-turbo-stream", "true");
    form.setAttribute("accept-charset", "UTF-8");

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

    // Intercept form submission to ensure we request turbo_stream format
    saveButton.addEventListener("click", async (e) => {
      e.preventDefault();

      const formData = new FormData(form);

      try {
        const response = await fetch(form.action, {
          method: "PATCH",
          headers: {
            "Accept": "text/vnd.turbo-stream.html",
            "X-Requested-With": "XMLHttpRequest",
            "X-CSRF-Token": this.csrfToken()
          },
          body: formData
        });

        if (response.ok) {
          const text = await response.text();
          // Let Turbo process the response - this will replace the DOM elements
          // including the inline editor, so no manual cleanup is needed
          Turbo.renderStreamMessage(text);
          // Reset state (but don't manipulate DOM since Turbo will replace it)
          this.editing = false;
          this.originalValue = null;
          this.inputElement = null;
          this.formElement = null;
          this.containerElement = null;
        } else {
          alert("Update failed");
          this.cleanup();
        }
      } catch (error) {
        console.error("Error submitting form:", error);
        alert("Update failed");
        this.cleanup();
      }
    });

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
