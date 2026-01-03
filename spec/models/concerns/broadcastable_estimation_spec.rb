require 'rails_helper'

RSpec.describe Broadcastable::Estimation, type: :concern do
  let(:user) { create(:user) }
  let(:estimation) { create(:estimation, user: user) }

  describe 'broadcasting' do
    it 'broadcasts on estimation creation' do
      new_estimation = nil
      expect {
        new_estimation = create(:estimation, user: user)
      }.to have_broadcasted_to("estimation_#{Estimation.maximum(:id).to_i + 1}").at_least(:once)
    end

    it 'broadcasts on estimation update' do
      expect {
        estimation.update(title: 'Updated Title')
      }.to have_broadcasted_to("estimation_#{estimation.id}").with(
        hash_including(type: 'estimation_update', estimation_id: estimation.id)
      )
    end

    it 'broadcasts on estimation deletion' do
      est_id = estimation.id
      
      expect {
        estimation.destroy
      }.to have_broadcasted_to("estimation_#{est_id}").with(
        hash_including(type: 'estimation_update', estimation_id: est_id)
      )
    end

    it 'includes a timestamp in the broadcast' do
      expect {
        estimation.update(title: 'New Title')
      }.to have_broadcasted_to("estimation_#{estimation.id}").with(
        hash_including(timestamp: kind_of(Integer))
      )
    end

    it 'includes action in the broadcast' do
      expect {
        estimation.update(title: 'New Title')
      }.to have_broadcasted_to("estimation_#{estimation.id}").with(
        hash_including(action: 'update')
      )
    end
  end

  describe 'payload size' do
    it 'keeps payload small and under limits' do
      # Create estimation with long title
      long_estimation = create(:estimation, user: user, title: 'A' * 255)
      
      # Use RSpec's broadcast matchers to verify
      expect {
        long_estimation.update(title: 'B' * 255)
      }.to have_broadcasted_to("estimation_#{long_estimation.id}")
      
      # Check that payload would be small by verifying structure
      # The broadcast includes only: type, estimation_id, action, timestamp
      # Each field is small, so total should be < 200 bytes
      broadcasts = ActionCable.server.pubsub.broadcasts("estimation_#{long_estimation.id}")
      expect(broadcasts).not_to be_empty
      
      broadcast_message = broadcasts.last
      payload_size = broadcast_message.bytesize
      expect(payload_size).to be < 8000
      expect(payload_size).to be < 200
    end

    it 'payload does not include large data' do
      estimation_with_items = create(:estimation, user: user)
      50.times { |i| create(:estimation_item, estimation: estimation_with_items, title: "Item #{i}" * 10) }
      
      estimation_with_items.update(title: 'Updated')
      
      # Verify payload structure via ActionCable test adapter
      broadcasts = ActionCable.server.pubsub.broadcasts("estimation_#{estimation_with_items.id}")
      expect(broadcasts).not_to be_empty
      
      broadcast_message = broadcasts.last
      # The test adapter stores broadcasts as JSON strings, parse it
      broadcast_payload = JSON.parse(broadcast_message)
      
      # Verify payload only contains essential data
      expect(broadcast_payload).to have_key('type')
      expect(broadcast_payload).to have_key('estimation_id')
      expect(broadcast_payload).to have_key('timestamp')
      expect(broadcast_payload).to have_key('action')
      
      # Verify small size
      expect(broadcast_message.bytesize).to be < 200
    end
  end
end
