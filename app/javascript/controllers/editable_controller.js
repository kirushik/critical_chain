import { Controller } from "@hotwired/stimulus";

// Stimulus controller for inline editing with Turbo Streams
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
  }

  edit(event) {
    event.preventDefault();
    if (this.editing) return;

    this.editing = true;
    this.originalValue = this.displayTarget.textContent.trim();

    // Add editing class to hide dashed underline
    this.element.classList.add("editing");

    // Create editable-inline container
    const container = document.createElement("span");
    container.className = "editable-inline";

    // Create form
    const form = document.createElement("div");
    form.className = "editable-input";

    // Create input element
    const input = document.createElement("input");
    input.type = this.typeValue === "number" ? "number" : "text";
    input.value = this.originalValue;
    input.name = `${this.element.closest("tr")?.id.split("_")[0] || "estimation"}_item_${this.nameValue}`;
    input.className = "form-control input-sm";
    
    // Match the width of the original display element to prevent layout shift
    const displayWidth = this.displayTarget.offsetWidth;
    const minWidth = this.typeValue === "number" ? 80 : 150;
    input.style.width = `${Math.max(displayWidth, minWidth)}px`;

    form.appendChild(input);
    container.appendChild(form);

    // Create buttons container
    const buttons = document.createElement("div");
    buttons.className = "editable-buttons";

    // Create save button
    const saveButton = document.createElement("button");
    saveButton.type = "button";
    saveButton.className = "btn btn-sm btn-success editable-submit";
    saveButton.innerHTML = '<i class="fa fa-check"></i>';
    saveButton.addEventListener("click", (e) => {
      e.preventDefault();
      e.stopPropagation();
      this.save();
    });

    // Create cancel button
    const cancelButton = document.createElement("button");
    cancelButton.type = "button";
    cancelButton.className = "btn btn-sm btn-default editable-cancel";
    cancelButton.innerHTML = '<i class="fa fa-times"></i>';
    cancelButton.addEventListener("click", (e) => {
      e.preventDefault();
      e.stopPropagation();
      this.cancel();
    });

    buttons.appendChild(saveButton);
    buttons.appendChild(cancelButton);
    container.appendChild(buttons);

    // Replace display with container
    this.displayTarget.style.display = "none";
    this.displayTarget.insertAdjacentElement("afterend", container);

    this.inputElement = input;
    this.containerElement = container;
    input.focus();
    input.select();

    // Handle Enter and Escape keys
    input.addEventListener("keydown", (e) => {
      if (e.key === "Enter") {
        e.preventDefault();
        this.save();
      } else if (e.key === "Escape") {
        e.preventDefault();
        this.cancel();
      }
    });

    // Handle blur (focus away) - cancel if value unchanged
    input.addEventListener("blur", (e) => {
      // Use setTimeout to allow button clicks to register first
      setTimeout(() => {
        // Check if we're still editing and the input still exists
        if (this.editing && this.inputElement && this.containerElement) {
          // Only cancel if value hasn't changed
          if (this.inputElement.value === this.originalValue) {
            this.cancel();
          }
        }
      }, 200);
    });
  }

  async save() {
    if (!this.editing) return;

    const newValue = this.inputElement.value;
    
    // If value hasn't changed, just cancel
    if (newValue === this.originalValue) {
      this.cancel();
      return;
    }

    // Create form data for Rails strong params
    const formData = new FormData();
    formData.append(`${this.modelValue}[${this.nameValue}]`, newValue);

    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "X-CSRF-Token": this.csrfToken(),
          "Accept": "text/vnd.turbo-stream.html",
        },
        body: formData,
      });

      if (response.ok) {
        // Don't cleanup the DOM here - let Turbo handle replacing the element
        // The turbo-stream response will replace the entire row/element
        // which automatically removes the inline editor
        // Just mark as not editing and clear references
        this.editing = false;
        this.inputElement = null;
        this.containerElement = null;
        // Note: We don't remove the editing class or touch the DOM
        // Turbo will replace the entire element which removes everything
      } else {
        const text = await response.text();
        alert(text || "Update failed");
        this.cancel();
      }
    } catch (error) {
      console.error("Update error:", error);
      alert("Update failed");
      this.cancel();
    }
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
    this.displayTarget.style.display = "";
    this.element.classList.remove("editing");
    this.editing = false;
  }

  csrfToken() {
    const meta = document.querySelector('meta[name="csrf-token"]');
    return meta ? meta.content : "";
  }
}
