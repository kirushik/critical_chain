require 'rails_helper'

RSpec.describe RealtimeBroadcastable::Estimation, type: :concern do
  let(:user) { create(:user) }
  let(:estimation) { create(:estimation, user: user) }

  describe 'broadcasting' do
    it 'broadcasts Turbo Stream on estimation update' do
      expect(Turbo::StreamsChannel).to receive(:broadcast_update_later_to).with(
        "estimation_#{estimation.id}",
        hash_including(targets: a_string_including('#estimation_title'))
      )
      
      estimation.update(title: 'Updated Title')
    end

    it 'does not broadcast on estimation creation' do
      expect(Turbo::StreamsChannel).not_to receive(:broadcast_update_later_to)
      
      create(:estimation, user: user)
    end

    it 'does not broadcast on estimation deletion' do
      expect(Turbo::StreamsChannel).not_to receive(:broadcast_update_later_to)
      
      estimation.destroy
    end
  end

  describe 'Turbo Stream content' do
    it 'sends only the escaped title text' do
      expect(Turbo::StreamsChannel).to receive(:broadcast_update_later_to) do |_stream, **opts|
        expect(opts[:html]).to eq('&lt;b&gt;New&lt;/b&gt; Title')
        expect(opts).not_to include(:partial)
      end

      estimation.update(title: '<b>New</b> Title')
    end
  end
end
