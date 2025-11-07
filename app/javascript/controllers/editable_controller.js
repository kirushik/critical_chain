import { Controller } from "@hotwired/stimulus"

// Stimulus controller for inline editing
export default class extends Controller {
  static targets = ["field", "input", "display"]
  static values = {
    url: String,
    name: String,
    type: { type: String, default: "text" },
    pk: Number
  }

  connect() {
    this.editing = false
  }

  edit(event) {
    event.preventDefault()
    if (this.editing) return

    this.editing = true
    const value = this.displayTarget.textContent.trim()
    
    // Create input element
    const input = document.createElement("input")
    input.type = this.typeValue === "number" ? "number" : "text"
    input.value = value
    input.className = "form-control form-control-sm d-inline-block"
    input.style.width = this.typeValue === "number" ? "100px" : "200px"
    
    // Create buttons container
    const buttons = document.createElement("span")
    buttons.className = "ms-1"
    buttons.innerHTML = `
      <button type="button" class="btn btn-sm btn-success" data-action="editable#save">
        <i class="fa fa-check"></i>
      </button>
      <button type="button" class="btn btn-sm btn-secondary" data-action="editable#cancel">
        <i class="fa fa-times"></i>
      </button>
    `
    
    // Replace display with input
    this.displayTarget.style.display = "none"
    this.displayTarget.insertAdjacentElement("afterend", input)
    this.displayTarget.insertAdjacentElement("afterend", buttons)
    
    this.inputElement = input
    this.buttonsElement = buttons
    input.focus()
    input.select()
    
    // Handle Enter key
    input.addEventListener("keydown", (e) => {
      if (e.key === "Enter") {
        e.preventDefault()
        this.save()
      } else if (e.key === "Escape") {
        e.preventDefault()
        this.cancel()
      }
    })
  }

  async save() {
    if (!this.editing) return
    
    const newValue = this.inputElement.value
    const data = {}
    data[this.nameValue] = newValue
    
    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken(),
          "Accept": "application/json"
        },
        body: JSON.stringify(data)
      })
      
      const result = await response.json()
      
      if (response.ok && result.success !== false) {
        this.displayTarget.textContent = newValue
        this.updateAdditionalValues(result.additionalValues)
        this.cleanup()
      } else {
        alert(result.msg || "Update failed")
        this.cancel()
      }
    } catch (error) {
      console.error("Update error:", error)
      alert("Update failed")
      this.cancel()
    }
  }

  cancel() {
    this.cleanup()
  }

  cleanup() {
    if (this.inputElement) {
      this.inputElement.remove()
      this.inputElement = null
    }
    if (this.buttonsElement) {
      this.buttonsElement.remove()
      this.buttonsElement = null
    }
    this.displayTarget.style.display = ""
    this.editing = false
  }

  updateAdditionalValues(vals) {
    if (!vals) return
    
    const updateElement = (id, value) => {
      const el = document.getElementById(id)
      if (el) el.textContent = value
    }
    
    if (vals.total) updateElement("total", vals.total)
    if (vals.sum) updateElement("sum", vals.sum)
    if (vals.buffer) updateElement("buffer", vals.buffer)
    if (vals.actual_sum) updateElement("actual_sum", vals.actual_sum)
    if (vals.buffer_health) updateElement("buffer_health", vals.buffer_health)
    
    if (vals.buffer_health_class) {
      const el = document.getElementById("buffer_health")
      if (el) el.className = vals.buffer_health_class
    }
    
    if (vals.update_item_total) {
      const itemEl = document.querySelector(vals.update_item_total.item + " .total_value")
      if (itemEl) itemEl.textContent = vals.update_item_total.total
    }
  }

  csrfToken() {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta ? meta.content : ""
  }
}
