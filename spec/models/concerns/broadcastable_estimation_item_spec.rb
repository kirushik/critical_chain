require 'rails_helper'

RSpec.describe Broadcastable::EstimationItem, type: :concern do
  let(:user) { create(:user) }
  let(:estimation) { create(:estimation, user: user) }

  describe 'broadcasting' do
    it 'broadcasts on estimation item creation' do
      expect {
        create(:estimation_item, estimation: estimation)
      }.to have_broadcasted_to("estimation_#{estimation.id}").with(
        hash_including(type: 'estimation_item_update', estimation_id: estimation.id, action: 'create')
      )
    end

    it 'broadcasts on estimation item update' do
      estimation_item = create(:estimation_item, estimation: estimation)
      
      expect {
        estimation_item.update(value: 999)
      }.to have_broadcasted_to("estimation_#{estimation.id}").with(
        hash_including(
          type: 'estimation_item_update',
          estimation_id: estimation.id,
          estimation_item_id: estimation_item.id,
          action: 'update'
        )
      )
    end

    it 'broadcasts on estimation item deletion' do
      estimation_item = create(:estimation_item, estimation: estimation)
      item_id = estimation_item.id
      
      expect {
        estimation_item.destroy
      }.to have_broadcasted_to("estimation_#{estimation.id}").with(
        hash_including(
          type: 'estimation_item_update',
          estimation_id: estimation.id,
          estimation_item_id: item_id,
          action: 'destroy'
        )
      )
    end

    it 'includes a timestamp in the broadcast' do
      estimation_item = create(:estimation_item, estimation: estimation)
      
      expect {
        estimation_item.update(value: 999)
      }.to have_broadcasted_to("estimation_#{estimation.id}").with(
        hash_including(timestamp: kind_of(Integer))
      )
    end
  end

  describe 'payload size' do
    it 'keeps payload small and under limits with large titles' do
      # Create item with very long title
      long_title = 'A' * 255
      item = create(:estimation_item, estimation: estimation, title: long_title)
      
      item.update(value: 999)
      
      # Check payload size using test adapter
      broadcasts = ActionCable.server.pubsub.broadcasts("estimation_#{estimation.id}")
      expect(broadcasts).not_to be_empty
      
      # Get the update broadcast (last one)
      broadcast_message = broadcasts.last
      expect(broadcast_message.bytesize).to be < 8000
      expect(broadcast_message.bytesize).to be < 200
    end

    it 'payload does not include item data, only IDs' do
      item = create(:estimation_item, estimation: estimation, title: 'Test Item' * 20)
      
      item.update(value: 999)
      
      # Verify payload structure via ActionCable test adapter
      broadcasts = ActionCable.server.pubsub.broadcasts("estimation_#{estimation.id}")
      expect(broadcasts).not_to be_empty
      
      # Get the update broadcast (last one)
      broadcast_message = broadcasts.last
      broadcast_payload = JSON.parse(broadcast_message)
      
      expect(broadcast_payload).to have_key('type')
      expect(broadcast_payload).to have_key('estimation_id')
      expect(broadcast_payload).to have_key('estimation_item_id')
      expect(broadcast_payload).to have_key('timestamp')
      expect(broadcast_payload).to have_key('action')
      
      # Should not include title, value, or other item data
      expect(broadcast_payload).not_to have_key('title')
      expect(broadcast_payload).not_to have_key('value')
      
      # Verify small size
      expect(broadcast_message.bytesize).to be < 200
    end
  end
end
