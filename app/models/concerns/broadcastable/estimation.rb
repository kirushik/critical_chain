# Broadcaster for Estimation model changes
# Broadcasts updates to viewers when an estimation is modified
module Broadcastable
  module Estimation
    extend ActiveSupport::Concern

    included do
      after_commit :broadcast_estimation_change, on: [:create, :update, :destroy]
    end

    private

    def broadcast_estimation_change
      return unless id
      return unless defined?(ActionCable) && ActionCable.server

      ActionCable.server.broadcast(
        "estimation_#{id}",
        {
          type: 'estimation_update',
          estimation_id: id,
          action: previous_changes.present? ? 'update' : 'create',
          timestamp: Time.current.to_i
        }
      )
    rescue => e
      Rails.logger.error "Failed to broadcast estimation change: #{e.message}"
    end
  end
end
