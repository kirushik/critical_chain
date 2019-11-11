require 'rails_helper'

RSpec.describe "estimations/_estimation.html.erb", :type => :view do
  it 'should render estimation\'s calculated values' do
    estimation = FactoryBot.create(:estimation_with_items, items: {size: 1, count: 4}).decorate

    render partial: "estimations/estimation", locals: { estimation: estimation }

    expect(rendered).to have_text('4 + 2 = 6')
  end
end