require 'rails_helper'

RSpec.describe RealtimeBroadcastable::Estimation, type: :concern do
  let(:user) { create(:user) }
  let(:estimation) { create(:estimation, user: user) }

  describe 'broadcasting' do
    it 'broadcasts Turbo Stream on estimation update' do
      expect(Turbo::StreamsChannel).to receive(:broadcast_replace_later_to).with(
        "estimation_#{estimation.id}",
        hash_including(target: "estimation_title", partial: "estimations/title")
      )
      
      estimation.update(title: 'Updated Title')
    end

    it 'does not broadcast on estimation creation' do
      expect(Turbo::StreamsChannel).not_to receive(:broadcast_replace_later_to)
      
      create(:estimation, user: user)
    end

    it 'does not broadcast on estimation deletion' do
      expect(Turbo::StreamsChannel).not_to receive(:broadcast_replace_later_to)
      
      estimation.destroy
    end
  end

  describe 'Turbo Stream content' do
    it 'passes decorated estimation to the partial' do
      expect(Turbo::StreamsChannel).to receive(:broadcast_replace_later_to) do |stream, **opts|
        expect(opts[:locals][:estimation]).to be_a(EstimationDecorator)
        expect(opts[:locals][:estimation].object).to eq(estimation)
      end
      
      estimation.update(title: 'New Title')
    end
  end
end
