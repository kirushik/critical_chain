import { Controller } from "@hotwired/stimulus";
import consumer from "../channels/consumer";

// Connects to data-controller="estimation-realtime"
export default class extends Controller {
  static values = {
    estimationId: Number,
    canEdit: Boolean
  }

  connect() {
    // Only subscribe if we're viewing an estimation
    if (this.hasEstimationIdValue && this.estimationIdValue > 0) {
      this.subscribe();
    }
  }

  disconnect() {
    this.unsubscribe();
  }

  subscribe() {
    this.subscription = consumer.subscriptions.create(
      {
        channel: "EstimationUpdatesChannel",
        estimation_id: this.estimationIdValue
      },
      {
        connected: () => {
          console.log(`Connected to estimation ${this.estimationIdValue} updates`);
        },

        disconnected: () => {
          console.log(`Disconnected from estimation ${this.estimationIdValue} updates`);
        },

        received: (data) => {
          // Only reload if we're a viewer (not the editor making changes)
          // The editor already sees their changes through Turbo Stream responses
          if (!this.canEditValue && data.type === 'update') {
            console.log(`Received update for estimation ${this.estimationIdValue}, reloading...`);
            // Use Turbo to visit the current URL, which will update the page
            Turbo.visit(window.location.href, { action: "replace" });
          }
        }
      }
    );
  }

  unsubscribe() {
    if (this.subscription) {
      this.subscription.unsubscribe();
      this.subscription = null;
    }
  }
}
