require 'rails_helper'

RSpec.describe RealtimeBroadcastable::EstimationItem, type: :concern do
  let(:user) { create(:user) }
  let(:estimation) { create(:estimation, user: user) }

  describe 'concern inclusion' do
    it 'includes the concern in EstimationItem' do
      expect(EstimationItem.ancestors).to include(RealtimeBroadcastable::EstimationItem)
    end
  end

  describe 'broadcast method behavior' do
    it 'does not raise error when broadcasting' do
      item = create(:estimation_item, estimation: estimation)
      
      expect {
        item.send(:broadcast_estimation_item_change)
      }.not_to raise_error
    end

    it 'handles destroyed items correctly' do
      item = create(:estimation_item, estimation: estimation)
      item.destroy
      
      expect {
        item.send(:broadcast_estimation_item_change)
      }.not_to raise_error
    end
  end
end
