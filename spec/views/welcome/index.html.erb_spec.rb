require 'rails_helper'

RSpec.describe "welcome/index.html.erb", :type => :view do
  it 'should contain user\'s private estimations' do
    estimations = (1..3).map { FactoryGirl.create(:estimation) }
    assign(:estimations, estimations)

    render

    expect(rendered.scan('<li>').size).to eq(3)
    estimations.each do |estimation|
      expect(rendered).to have_text(estimation.title)
    end
  end
end
