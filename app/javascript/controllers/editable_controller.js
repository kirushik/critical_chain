import { Controller } from "@hotwired/stimulus";

// Stimulus controller for inline editing (x-editable compatible)
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
    const value = this.displayTarget.textContent.trim();

    // Create editable-inline container (x-editable compatible)
    const container = document.createElement("span");
    container.className = "editable-inline";

    // Create form
    const form = document.createElement("div");
    form.className = "editable-input";

    // Create input element
    const input = document.createElement("input");
    input.type = this.typeValue === "number" ? "number" : "text";
    input.value = value;
    input.name = `${this.element.closest("tr")?.id.split("_")[0] || "estimation"}_item_${this.nameValue}`;
    input.className = "form-control input-sm";
    input.style.width = this.typeValue === "number" ? "100px" : "200px";

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
      this.save();
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
  }

  async save() {
    if (!this.editing) return;

    const newValue = this.inputElement.value;
    // Wrap data in model namespace for Rails strong params
    const data = { [this.modelValue]: {} };
    data[this.modelValue][this.nameValue] = newValue;

    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken(),
          "X-Requested-With": "XMLHttpRequest",
          Accept: "application/json",
        },
        body: JSON.stringify(data),
      });

      const result = await response.json();

      if (response.ok && result.success !== false) {
        this.displayTarget.textContent = newValue;
        this.updateAdditionalValues(result.additionalValues);
        this.cleanup();
      } else {
        alert(result.msg || "Update failed");
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
    this.editing = false;
  }

  updateAdditionalValues(vals) {
    if (!vals) return;

    const updateElement = (id, value) => {
      const el = document.getElementById(id);
      if (el) el.textContent = value;
    };

    if (vals.total) updateElement("total", vals.total);
    if (vals.sum) updateElement("sum", vals.sum);
    if (vals.buffer) updateElement("buffer", vals.buffer);
    if (vals.actual_sum) updateElement("actual_sum", vals.actual_sum);
    if (vals.buffer_health) updateElement("buffer_health", vals.buffer_health);

    if (vals.buffer_health_class) {
      const el = document.getElementById("buffer_health");
      if (el) el.className = vals.buffer_health_class;
    }

    if (vals.update_item_total) {
      const itemEl = document.querySelector(
        vals.update_item_total.item + " .total_value",
      );
      if (itemEl) itemEl.textContent = vals.update_item_total.total;
    }
  }

  csrfToken() {
    const meta = document.querySelector('meta[name="csrf-token"]');
    return meta ? meta.content : "";
  }
}
