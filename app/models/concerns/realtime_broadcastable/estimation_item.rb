# Broadcaster for EstimationItem model changes
# Broadcasts Turbo Stream updates to viewers when an estimation item is modified
module RealtimeBroadcastable
  module EstimationItem
    extend ActiveSupport::Concern

    included do
      after_commit :broadcast_estimation_item_change, on: [:create, :update, :destroy]
    end

    private

    def broadcast_estimation_item_change
      return unless estimation_id
      return unless defined?(Turbo)

      # Reload the estimation with items to get fresh data
      # Use find_by to handle cascade deletes gracefully (estimation may already be gone)
      est = ::Estimation.includes(:estimation_items).find_by(id: estimation_id)
      return unless est
      est_decorated = est.decorate
      
      if destroyed?
        # Remove the deleted item
        Turbo::StreamsChannel.broadcast_remove_to(
          "estimation_#{estimation_id}",
          target: ActionView::RecordIdentifier.dom_id(self)
        )
      elsif previous_changes.key?('id')
        # Append new item (all broadcast subscribers are editors)
        Turbo::StreamsChannel.broadcast_append_later_to(
          "estimation_#{estimation_id}",
          target: ActionView::RecordIdentifier.dom_id(est),
          partial: est_decorated.items_partial_name,
          locals: { estimation_item: self, can_edit: true }
        )
      else
        # Replace updated item (all broadcast subscribers are editors)
        Turbo::StreamsChannel.broadcast_replace_later_to(
          "estimation_#{estimation_id}",
          target: ActionView::RecordIdentifier.dom_id(self),
          partial: est_decorated.items_partial_name,
          locals: { estimation_item: self, can_edit: true }
        )
      end

      # Always update the totals
      Turbo::StreamsChannel.broadcast_replace_later_to(
        "estimation_#{estimation_id}",
        target: "total",
        html: est_decorated.total
      )
      Turbo::StreamsChannel.broadcast_replace_later_to(
        "estimation_#{estimation_id}",
        target: "sum",
        html: est_decorated.sum
      )
      Turbo::StreamsChannel.broadcast_replace_later_to(
        "estimation_#{estimation_id}",
        target: "buffer",
        html: est_decorated.buffer
      )
      
      # Update tracking mode specific elements if applicable
      if est.tracking_mode?
        Turbo::StreamsChannel.broadcast_replace_later_to(
          "estimation_#{estimation_id}",
          target: "actual_sum",
          html: est_decorated.actual_sum.to_s
        )
        Turbo::StreamsChannel.broadcast_replace_later_to(
          "estimation_#{estimation_id}",
          target: "buffer_health",
          partial: "estimations/buffer_health",
          locals: { estimation: est_decorated }
        )
      end
    rescue => e
      Rails.logger.error "Failed to broadcast estimation item change: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
    end
  end
end
