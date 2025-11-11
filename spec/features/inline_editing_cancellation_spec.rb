require "rails_helper"

feature "InlineEditingCancellation", :type => :feature do
  let(:user) { FactoryBot.create(:user_with_nonempty_estimations) }
  let(:estimation) { user.estimations.first }
  let(:estimation_item) { estimation.estimation_items.first }

  let(:new_title) { "New Title That Should Not Be Saved" }
  let(:new_value) { 999 }

  before(:each) do
    login_as user
    visit estimation_path(estimation)
  end

  scenario "I can cancel editing with the Cancel button", :playwright do
    original_title = estimation_item.title
    expect(page.get_by_text(original_title)).to be_visible

    # Click to open editor
    page.locator("span.editable.title:has-text('#{original_title}')").click
    expect(page.locator(".editable-inline")).to be_visible

    # Change the value
    page.locator(".editable-inline .editable-input input").fill(new_title)

    # Click the Cancel button
    page.locator(".editable-inline .editable-cancel").click

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

  scenario "I can cancel editing by clicking away if value unchanged", :playwright do
    original_value = estimation_item.value
    
    # Click to open editor
    page.locator("span.editable.value:has-text('#{original_value}')").click
    expect(page.locator(".editable-inline")).to be_visible

    # Don't change the value, just click away
    page.locator("h1").click

    # Wait for editor to close automatically
    page.locator(".editable-inline").wait_for(state: 'hidden', timeout: 5000)

    # Verify the original value is still displayed
    expect(page.locator("span.editable.value:has-text('#{original_value}')").first).to be_visible
    expect(page.locator(".editable-inline").count).to eq(0)
  end

  scenario "Blur does not cancel if value was changed", :playwright do
    original_value = estimation_item.value
    new_value = original_value + 100
    
    # Click to open editor
    page.locator("span.editable.value:has-text('#{original_value}')").click
    expect(page.locator(".editable-inline")).to be_visible

    # Change the value
    page.locator(".editable-inline .editable-input input").fill(new_value.to_s)

    # Click away
    page.locator("h1").click

    # Wait a bit to see if editor closes
    page.wait_for_timeout(300)

    # Editor should still be visible since value changed
    expect(page.locator(".editable-inline").count).to eq(1)
    
    # Now cancel with escape
    page.locator(".editable-inline .editable-input input").press('Escape')
    
    # Verify editor closed
    page.locator(".editable-inline").wait_for(state: 'hidden', timeout: 5000)
  end

  scenario "Cancel button works for estimation title", :playwright do
    original_title = estimation.title
    expect(page.get_by_text(original_title)).to be_visible

    # Click to open editor
    page.locator("h1 span.editable.title:has-text('#{original_title}')").click
    expect(page.locator(".editable-inline")).to be_visible

    # Change the value
    page.locator(".editable-inline .editable-input input").fill(new_title)

    # Click the Cancel button
    page.locator(".editable-inline .editable-cancel").click

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
end
