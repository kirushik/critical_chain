# Broadcaster for Estimation model changes
# Broadcasts Turbo Stream updates to viewers when an estimation is modified
module RealtimeBroadcastable
  module Estimation
    extend ActiveSupport::Concern

    included do
      after_commit :broadcast_estimation_change, on: [:update]
    end

    private

    def broadcast_estimation_change
      return unless id
      return unless defined?(Turbo)

      # Broadcast Turbo Stream update to viewers
      # This renders the updated estimation title in place
      Turbo::StreamsChannel.broadcast_replace_later_to(
        "estimation_#{id}",
        target: "estimation_title",
        partial: "estimations/title",
        locals: { estimation: decorate }
      )
    rescue => e
      Rails.logger.error "Failed to broadcast estimation change: #{e.message}"
    end
  end
end
