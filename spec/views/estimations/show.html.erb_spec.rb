require 'rails_helper'

RSpec.describe "estimations/show.html.erb", :type => :view do
  let(:estimation) { FactoryGirl.create(:estimation_with_items) }

  it 'lists the values of the estimation items' do
    assign(:estimation, estimation)

    render

    estimation.estimation_items.each do |item|
      expect(rendered).to have_text(item.value)
    end
  end
end
