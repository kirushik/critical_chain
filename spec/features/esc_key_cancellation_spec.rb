require "rails_helper"

feature "EscKeyCancellation", :type => :feature do
  let(:user) { FactoryBot.create(:user_with_nonempty_estimations) }
  let(:estimation) { user.estimations.first }
  let(:estimation_item) { estimation.estimation_items.first }

  let(:new_title) { "New Title That Should Not Be Saved" }
  let(:new_value) { 999 }

  before(:each) do
    login_as user
    visit estimation_path(estimation)
  end

  scenario "I can cancel editing estimation title with ESC key", :js do
    original_title = estimation.title
    expect(page).to have_text original_title

    # Click to open editor
    page.find("h1 span.editable.title", text: original_title).click
    expect(page).to have_css(".editable-inline")

    # Change the value
    page.find(".editable-inline .editable-input input").set new_title

    # Press ESC to cancel
    page.find(".editable-inline .editable-input input").send_keys(:escape)

    # Verify the original title is still displayed
    expect(page).to have_text original_title
    expect(page).to have_no_text new_title
    expect(page).to have_no_css(".editable-inline")

    # Refresh and verify the change was not saved
    visit current_path
    expect(page).to have_text original_title
    expect(page).to have_no_text new_title
  end

  scenario "I can cancel editing estimation item title with ESC key", :js do
    original_title = estimation_item.title
    expect(page).to have_text original_title

    # Click to open editor
    page.find("span.editable.title", text: original_title).click
    expect(page).to have_css(".editable-inline")

    # Change the value
    page.find(".editable-inline .editable-input input").set new_title

    # Press ESC to cancel
    page.find(".editable-inline .editable-input input").send_keys(:escape)

    # Verify the original title is still displayed
    expect(page).to have_text original_title
    expect(page).to have_no_text new_title
    expect(page).to have_no_css(".editable-inline")

    # Refresh and verify the change was not saved
    visit current_path
    expect(page).to have_text original_title
    expect(page).to have_no_text new_title
  end

  scenario "I can cancel editing estimation item value with ESC key", :js do
    original_value = estimation_item.value
    expect(page).to have_text original_value

    # Click to open editor
    page.find("span.editable.value", text: original_value).click
    expect(page).to have_css(".editable-inline")

    # Change the value
    page.find(".editable-inline .editable-input input").set new_value

    # Press ESC to cancel
    page.find(".editable-inline .editable-input input").send_keys(:escape)

    # Verify the original value is still displayed
    expect(page).to have_text original_value
    expect(page).to have_no_text new_value
    expect(page).to have_no_css(".editable-inline")

    # Refresh and verify the change was not saved
    visit current_path
    expect(page).to have_text original_value
    expect(page).to have_no_text new_value
  end

  scenario "I can cancel editing estimation item quantity with ESC key", :js do
    original_quantity = estimation_item.quantity
    new_quantity = 42

    # Click to open editor
    page.find("span.editable.quantity").click
    expect(page).to have_css(".editable-inline")

    # Change the value
    page.find(".editable-inline .editable-input input").set new_quantity

    # Press ESC to cancel
    page.find(".editable-inline .editable-input input").send_keys(:escape)

    # Verify the editor is closed
    expect(page).to have_no_css(".editable-inline")

    # Refresh and verify the change was not saved
    visit current_path
    page.find("span.editable.quantity").click
    expect(page).to have_css(".editable-inline")

    # The original quantity should still be there
    input_value = page.find(".editable-inline .editable-input input").value
    expect(input_value).to eq(original_quantity.to_s)
  end
end
