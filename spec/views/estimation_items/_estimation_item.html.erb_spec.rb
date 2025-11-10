require "rails_helper"

RSpec.describe "estimation_items/_estimation_item.html.erb", :type => :view do
  it "should render fa-toggle-off icon for non-fixed items" do
    estimation_item = FactoryBot.create(:estimation_item, fixed: false)
    render partial: "estimation_items/estimation_item", locals: { estimation_item: estimation_item }
    expect(rendered).to have_css(".fa-toggle-off")
  end

  it "should render fa-toggle-on icon for fixed items" do
    estimation_item = FactoryBot.create(:estimation_item, fixed: true)
    render partial: "estimation_items/estimation_item", locals: { estimation_item: estimation_item }
    expect(rendered).to have_css(".fa-toggle-on")
  end

  it "should render number editor for batch items" do
    estimation_item = FactoryBot.create(:estimation_item, quantity: 17)
    render partial: "estimation_items/estimation_item", locals: { estimation_item: estimation_item }

    html = Nokogiri::HTML.parse(rendered)

    expect(html.css(".fa-copy")).not_to be_empty
    # Check for Stimulus controller data attributes instead of old x-editable data-value
    expect(html.css(".quantity").first.attributes["data-editable-target"]).not_to be_nil
  end

  it "should multiply subitem estimate and quantity" do
    foo = FactoryBot.create(:estimation_item, quantity: 3, value: 7)
    render partial: "estimation_items/estimation_item", locals: { estimation_item: foo }

    html = Nokogiri::HTML.parse(rendered)

    expect(html.css(".multiplier-total").text).to include("21")
  end
end
