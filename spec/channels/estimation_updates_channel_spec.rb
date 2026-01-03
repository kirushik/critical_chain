require 'rails_helper'

RSpec.describe EstimationUpdatesChannel, type: :channel do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:estimation) { create(:estimation, user: user) }

  before do
    stub_connection current_user: user
  end

  describe '#subscribed' do
    context 'when user owns the estimation' do
      it 'successfully subscribes to the stream' do
        subscribe(estimation_id: estimation.id)
        
        expect(subscription).to be_confirmed
        expect(subscription).to have_stream_from("estimation_#{estimation.id}")
      end
    end

    context 'when estimation is shared with user' do
      before do
        create(:estimation_share, estimation: estimation, shared_with_user: other_user)
        stub_connection current_user: other_user
      end

      it 'successfully subscribes to the stream' do
        subscribe(estimation_id: estimation.id)
        
        expect(subscription).to be_confirmed
        expect(subscription).to have_stream_from("estimation_#{estimation.id}")
      end
    end

    context 'when user does not have access to estimation' do
      before do
        stub_connection current_user: other_user
      end

      it 'rejects the subscription' do
        subscribe(estimation_id: estimation.id)
        
        expect(subscription).to be_rejected
      end
    end

    context 'when estimation does not exist' do
      it 'raises an error' do
        expect {
          subscribe(estimation_id: 999999)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#unsubscribed' do
    it 'stops all streams' do
      subscribe(estimation_id: estimation.id)
      
      expect(subscription).to have_stream_from("estimation_#{estimation.id}")
      
      unsubscribe
      
      expect(subscription.streams).to be_empty
    end
  end
end
