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
    original_value = estimation_item.value
    new_quantity = 42

    # Get initial calculation values using CSS selectors (more reliable)
    initial_sum = page.find("#sum").text.to_i
    initial_buffer = page.find("#buffer").text.to_i
    initial_total = page.find("#total").text.to_i

    # Verify initial values match expected calculation
    expected_sum = original_quantity * original_value
    expect(initial_sum).to eq(expected_sum)

    # Click to open editor
    page.find("span.editable.quantity").click
    expect(page).to have_css(".editable-inline")

    # Change the value
    input = page.find(".editable-inline .editable-input input")
    input.set new_quantity

    # Press ESC to cancel
    input.send_keys(:escape)

    # Verify the editor is closed
    expect(page).to have_no_css(".editable-inline")

    # Verify the calculation values haven't changed (quantity was not changed)
    expect(page.find("#sum").text.to_i).to eq(initial_sum)
    expect(page.find("#buffer").text.to_i).to eq(initial_buffer)
    expect(page.find("#total").text.to_i).to eq(initial_total)

    # Refresh and verify the change was not saved
    visit current_path
    expect(page.find("#sum").text.to_i).to eq(initial_sum)
    expect(page.find("#buffer").text.to_i).to eq(initial_buffer)
    expect(page.find("#total").text.to_i).to eq(initial_total)
  end
end
