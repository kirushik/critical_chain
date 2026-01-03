# Broadcaster for EstimationItem model changes
# Broadcasts updates to viewers when an estimation item is modified
module Broadcastable
  module EstimationItem
    extend ActiveSupport::Concern

    included do
      after_commit :broadcast_estimation_item_change, on: [:create, :update, :destroy]
    end

    private

    def broadcast_estimation_item_change
      return unless estimation_id
      return unless defined?(ActionCable) && ActionCable.server

      # Determine action based on the callback context
      action = if destroyed?
                 'destroy'
               elsif previous_changes.key?('id') # New record
                 'create'
               else
                 'update'
               end

      ActionCable.server.broadcast(
        "estimation_#{estimation_id}",
        {
          type: 'estimation_item_update',
          estimation_id: estimation_id,
          estimation_item_id: id,
          action: action,
          timestamp: Time.current.to_i
        }
      )
    rescue => e
      Rails.logger.error "Failed to broadcast estimation item change: #{e.message}"
    end
  end
end
