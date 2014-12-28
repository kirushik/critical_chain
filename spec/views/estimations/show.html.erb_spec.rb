require 'rails_helper'

RSpec.describe "estimations/show.html.erb", :type => :view do
  let(:estimation) { FactoryGirl.create(:estimation_with_items, items: {count: 2, size: 2}).decorate }

  before(:each) do 
    assign(:estimation, estimation)
    render
  end

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
end
