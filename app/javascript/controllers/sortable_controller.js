import { Controller } from "@hotwired/stimulus"

// Stimulus controller for drag-and-drop sorting
export default class extends Controller {
  static targets = ["item"]

  connect() {
    this.draggedItem = null
  }

  dragStart(event) {
    this.draggedItem = event.currentTarget
    this.draggedItem.classList.add("dragging")
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/html", this.draggedItem.innerHTML)
  }

  dragEnd(event) {
    if (this.draggedItem) {
      this.draggedItem.classList.remove("dragging")
    }
    
    // Update order on server
    if (this.draggedItem && this.orderChanged) {
      this.updateOrder()
    }
    
    this.draggedItem = null
    this.orderChanged = false
  }

  dragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
    
    const afterElement = this.getDragAfterElement(event.clientY)
    const container = this.element.querySelector("tbody")
    
    if (afterElement == null) {
      container.appendChild(this.draggedItem)
    } else {
      container.insertBefore(this.draggedItem, afterElement)
    }
    
    this.orderChanged = true
  }

  getDragAfterElement(y) {
    const draggableElements = [...this.itemTargets].filter(item => 
      item !== this.draggedItem && !item.classList.contains("dragging")
    )

    return draggableElements.reduce((closest, child) => {
      const box = child.getBoundingClientRect()
      const offset = y - box.top - box.height / 2
      
      if (offset < 0 && offset > closest.offset) {
        return { offset: offset, element: child }
      } else {
        return closest
      }
    }, { offset: Number.NEGATIVE_INFINITY }).element
  }

  async updateOrder() {
    const item = this.draggedItem
    const itemId = item.id.split("_").pop()
    
    // Get the update URL from the table's data attribute
    const updateUrl = this.element.dataset.sortableUpdateUrl
    if (!updateUrl) {
      console.error("No update URL provided in data-sortable-update-url")
      return
    }
    
    // Get previous and next items
    const prevItem = item.previousElementSibling
    const nextItem = item.nextElementSibling
    
    // Calculate new order
    const prevOrder = prevItem ? parseFloat(prevItem.dataset.order) : 0
    const nextOrder = nextItem ? parseFloat(nextItem.dataset.order) : prevOrder + 2
    const newOrder = (prevOrder + nextOrder) / 2
    
    // Update data attribute
    item.dataset.order = newOrder
    
    try {
      const response = await fetch(`${updateUrl}/${itemId}`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken(),
          "Accept": "application/json"
        },
        body: JSON.stringify({
          estimation_item: {
            order: newOrder
          }
        })
      })
      
      if (!response.ok) {
        console.error("Failed to update order")
        // Could revert the order here if needed
      }
    } catch (error) {
      console.error("Failed to update order:", error)
    }
  }

  csrfToken() {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta ? meta.content : ""
  }
}
