require 'rails_helper'

RSpec.describe "estimations/show.html.erb", :type => :view do

  before(:each) do
    assign(:estimation, estimation)

    # Stub the Pundit policy helper for view specs
    policy_double = double('EstimationPolicy', manage_shares?: false)
    without_partial_double_verification do
      allow(view).to receive(:policy).with(estimation).and_return(policy_double)
      allow(view).to receive(:current_user).and_return(estimation.user)
    end

    render
  end

  context 'in planning mode' do
    let(:estimation) { FactoryBot.create(:estimation_with_items, items: {count: 2, size: 2}).decorate }

    it 'lists the values of the estimation items' do
      estimation.estimation_items.each do |item|
        expect(rendered).to have_text(item.value)
      end
    end

    it "shows the calculated optimistic value" do
      expect(rendered).to have_text(estimation.sum)
    end

    it "shows the rounded buffer value" do
      expect(rendered).to have_text(2.83)
    end

    it 'shows the rounded total value' do
      expect(rendered).to have_text(6.83)
    end

    it 'shows tracking mode toggle' do
      expect(rendered).to have_css('.tracking-toggle-button')
    end

    it 'doesn\'t show buffer consumption' do
      expect(rendered).not_to have_text(estimation.buffer_health)
    end
  end

  context 'in tracking mode' do
    let(:estimation) do
      estimation = FactoryBot.create(:estimation, tracking_mode: true)
      FactoryBot.create :estimation_item, value: 2, actual_value: 3, estimation: estimation
      FactoryBot.create :estimation_item, value: 2, actual_value: 10, estimation: estimation
      estimation.decorate
    end

    it 'shows sum of actual values' do
      expect(rendered).to have_text(estimation.actual_sum)
    end

    it 'shows buffer consumption' do
      expect(rendered).to have_text(estimation.buffer_health)
    end
  end
end
