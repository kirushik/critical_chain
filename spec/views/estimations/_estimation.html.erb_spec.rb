require 'rails_helper'

RSpec.describe "estimations/_estimation.html.erb", :type => :view do
  it 'should render estimation\'s calculated values' do
    estimation = FactoryGirl.create(:estimation_with_items, items: {size: 1, count: 4})
    
    render partial: "estimations/estimation", locals: { estimation: estimation }

    expect(rendered).to have_text('4 + 2 = 6')
  end
end