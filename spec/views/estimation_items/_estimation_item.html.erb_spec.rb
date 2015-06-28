require 'rails_helper'

RSpec.describe "estimation_items/_estimation_item.html.erb", :type => :view do
  it 'should render fa-toggle-off icon for non-fixed items' do
    estimation_item = FactoryGirl.create(:estimation_item, fixed: false)
    render partial: "estimation_items/estimation_item", locals: { estimation_item: estimation_item }
    expect(rendered).to have_css('.fa-toggle-off')
  end

  it 'should render fa-toggle-on icon for fixed items' do
    estimation_item = FactoryGirl.create(:estimation_item, fixed: true)
    render partial: "estimation_items/estimation_item", locals: { estimation_item: estimation_item }
    expect(rendered).to have_css('.fa-toggle-on')
  end

end