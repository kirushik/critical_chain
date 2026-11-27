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

      # Update only the title text: the header around it differs per viewer
      # (the owner's is editable and has the Sharing button), so one broadcast
      # rendering of it would be wrong for someone. html: goes out unescaped.
      Turbo::StreamsChannel.broadcast_update_later_to(
        "estimation_#{id}",
        targets: "#estimation_title .editable-display, #estimation_title .estimation-title-text",
        html: ERB::Util.html_escape(title)
      )
    rescue => e
      Rails.logger.error "Failed to broadcast estimation change: #{e.message}"
    end
  end
end
