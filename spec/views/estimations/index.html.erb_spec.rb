require 'rails_helper'

RSpec.describe "estimations/index.html.erb", :type => :view do
  it 'should contain user\'s private estimations' do
    estimations = (1..3).map { FactoryBot.create(:estimation) }
    assign(:estimations, estimations)

    render

    expect(rendered).to have_selector('.estimation-item', count: 3)
    estimations.each do |estimation|
      expect(rendered).to have_text(estimation.title)
    end
  end
end
