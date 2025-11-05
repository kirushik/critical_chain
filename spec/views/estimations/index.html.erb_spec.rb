require 'rails_helper'

RSpec.describe "estimations/index.html.erb", :type => :view do
  it 'should contain user\'s private estimations' do
    estimations = (1..3).map { FactoryBot.create(:estimation) }
    assign(:estimations, estimations)

    render

    expect(rendered.scan('</a>').size).to eq(6) # Counting number of links; Each estimation has 2 links (title + stats)
    estimations.each do |estimation|
      expect(rendered).to have_text(estimation.title)
    end
  end
end
