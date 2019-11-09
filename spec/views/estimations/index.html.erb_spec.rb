require 'rails_helper'

RSpec.describe "estimations/index.html.erb", :type => :view do
  it 'should contain user\'s private estimations' do
    estimations = (1..3).map { FactoryBot.create(:estimation) }
    assign(:estimations, estimations)

    render

    expect(rendered.scan('</a>').size).to eq(3) # Counting number of links; Closing tags are always look the same → PROFIT
    estimations.each do |estimation|
      expect(rendered).to have_text(estimation.title)
    end
  end
end
