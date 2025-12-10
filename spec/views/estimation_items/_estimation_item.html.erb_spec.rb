require "rails_helper"

RSpec.describe "estimation_items/_estimation_item.html.erb", :type => :view do
  let(:owner) { FactoryBot.create(:user) }

  before do
    allow(view).to receive(:current_user).and_return(owner)
  end

  it "should render circle icon for non-fixed items" do
    estimation_item = FactoryBot.create(:estimation_item, fixed: false, estimation: FactoryBot.create(:estimation, user: owner))
    render partial: "estimation_items/estimation_item", locals: { estimation_item: estimation_item }
    expect(rendered).to have_css(".fa-circle")
  end

  it "should render thumbtack icon for fixed items" do
    estimation_item = FactoryBot.create(:estimation_item, fixed: true, estimation: FactoryBot.create(:estimation, user: owner))
    render partial: "estimation_items/estimation_item", locals: { estimation_item: estimation_item }
    expect(rendered).to have_css(".fa-thumbtack")
  end

  it "should render number editor for batch items" do
    estimation_item = FactoryBot.create(:estimation_item, quantity: 17, estimation: FactoryBot.create(:estimation, user: owner))
    render partial: "estimation_items/estimation_item", locals: { estimation_item: estimation_item }

    html = Nokogiri::HTML.parse(rendered)

    expect(html.css(".fa-clone")).not_to be_empty
    # Check for Stimulus controller data attributes instead of old x-editable data-value
    expect(html.css(".quantity .editable-field").first.attributes["data-controller"].value).to eq("editable")
  end

  it "should always show quantity editor, even for quantity=1" do
    estimation_item = FactoryBot.create(:estimation_item, quantity: 1, estimation: FactoryBot.create(:estimation, user: owner))
    render partial: "estimation_items/estimation_item", locals: { estimation_item: estimation_item }

    html = Nokogiri::HTML.parse(rendered)

    # Quantity editor should be visible even when quantity is 1
    expect(html.css(".quantity .editable-field")).not_to be_empty
    expect(html.css(".fa-clone")).not_to be_empty
  end

  it "should multiply subitem estimate and quantity" do
    foo = FactoryBot.create(:estimation_item, quantity: 3, value: 7, estimation: FactoryBot.create(:estimation, user: owner))
    render partial: "estimation_items/estimation_item", locals: { estimation_item: foo }

    html = Nokogiri::HTML.parse(rendered)

    expect(html.css(".total").text).to include("21")
  end
end
