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

  scenario "I can cancel editing estimation title with ESC key", :playwright do
    original_title = estimation.title
    expect(page.get_by_text(original_title)).to be_visible

    # Click to open editor
    page.locator("h1 span.editable.title:has-text('#{original_title}')").click
    expect(page.locator(".editable-inline")).to be_visible

    # Change the value
    page.locator(".editable-inline .editable-input input").fill(new_title)

    # Press ESC to cancel
    page.locator(".editable-inline .editable-input input").press('Escape')

    # Wait for editor to close
    page.locator(".editable-inline").wait_for(state: 'hidden', timeout: 5000)

    # Verify the original title is still displayed
    expect(page.get_by_text(original_title)).to be_visible
    expect(page.get_by_text(new_title).count).to eq(0)
    expect(page.locator(".editable-inline").count).to eq(0)

    # Refresh and verify the change was not saved
    visit estimation_path(estimation)
    expect(page.get_by_text(original_title)).to be_visible
    expect(page.get_by_text(new_title).count).to eq(0)
  end

  scenario "I can cancel editing estimation item title with ESC key", :playwright do
    original_title = estimation_item.title
    expect(page.get_by_text(original_title)).to be_visible

    # Click to open editor
    page.locator("span.editable.title:has-text('#{original_title}')").click
    expect(page.locator(".editable-inline")).to be_visible

    # Change the value
    page.locator(".editable-inline .editable-input input").fill(new_title)

    # Press ESC to cancel
    page.locator(".editable-inline .editable-input input").press('Escape')

    # Wait for editor to close
    page.locator(".editable-inline").wait_for(state: 'hidden', timeout: 5000)

    # Verify the original title is still displayed
    expect(page.get_by_text(original_title)).to be_visible
    expect(page.get_by_text(new_title).count).to eq(0)
    expect(page.locator(".editable-inline").count).to eq(0)

    # Refresh and verify the change was not saved
    visit estimation_path(estimation)
    expect(page.get_by_text(original_title)).to be_visible
    expect(page.get_by_text(new_title).count).to eq(0)
  end

  scenario "I can cancel editing estimation item value with ESC key", :playwright do
    original_value = estimation_item.value
    expect(page.locator("span.editable.value:has-text('#{original_value}')").first).to be_visible

    # Click to open editor
    page.locator("span.editable.value:has-text('#{original_value}')").click
    expect(page.locator(".editable-inline")).to be_visible

    # Change the value
    page.locator(".editable-inline .editable-input input").fill(new_value.to_s)

    # Press ESC to cancel
    page.locator(".editable-inline .editable-input input").press('Escape')

    # Wait for editor to close
    page.locator(".editable-inline").wait_for(state: 'hidden', timeout: 5000)

    # Verify the original value is still displayed
    expect(page.locator("span.editable.value:has-text('#{original_value}')").first).to be_visible
    expect(page.get_by_text(new_value.to_s).count).to eq(0)
    expect(page.locator(".editable-inline").count).to eq(0)

    # Refresh and verify the change was not saved
    visit estimation_path(estimation)
    expect(page.locator("span.editable.value:has-text('#{original_value}')").first).to be_visible
    expect(page.get_by_text(new_value.to_s).count).to eq(0)
  end

  scenario "I can cancel editing estimation item quantity with ESC key", :playwright do
    original_quantity = estimation_item.quantity
    original_value = estimation_item.value
    new_quantity = 42

    # Get initial calculation values using CSS selectors (more reliable)
    initial_sum = page.locator("#sum").inner_text.to_i
    initial_buffer = page.locator("#buffer").inner_text.to_i
    initial_total = page.locator("#total").inner_text.to_i

    # Verify initial values match expected calculation
    expected_sum = original_quantity * original_value
    expect(initial_sum).to eq(expected_sum)

    # Click to open editor
    page.locator("span.editable.quantity").click
    expect(page.locator(".editable-inline")).to be_visible

    # Change the value
    input = page.locator(".editable-inline .editable-input input")
    input.fill(new_quantity.to_s)

    # Press ESC to cancel
    input.press('Escape')

    # Verify the editor is closed
    page.locator(".editable-inline").wait_for(state: 'hidden', timeout: 5000)
    expect(page.locator(".editable-inline").count).to eq(0)

    # Verify the calculation values haven't changed (quantity was not changed)
    expect(page.locator("#sum").inner_text.to_i).to eq(initial_sum)
    expect(page.locator("#buffer").inner_text.to_i).to eq(initial_buffer)
    expect(page.locator("#total").inner_text.to_i).to eq(initial_total)

    # Refresh and verify the change was not saved
    visit estimation_path(estimation)
    expect(page.locator("#sum").inner_text.to_i).to eq(initial_sum)
    expect(page.locator("#buffer").inner_text.to_i).to eq(initial_buffer)
    expect(page.locator("#total").inner_text.to_i).to eq(initial_total)
  end
end
