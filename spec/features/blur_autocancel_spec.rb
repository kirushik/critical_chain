require "rails_helper"

feature "BlurAutocancel", :type => :feature do
  let(:user) { FactoryBot.create(:user_with_nonempty_estimations) }
  let(:estimation) { user.estimations.first }
  let(:estimation_item) { estimation.estimation_items.first }

  before(:each) do
    login_as user
    visit estimation_path(estimation)
  end

  scenario "Estimation title editor auto-cancels on blur without changes", :playwright do
    original_title = estimation.title
    expect(page.get_by_text(original_title)).to be_visible

    # Click to open editor (scope to h1 to avoid matching estimation_item titles)
    page.locator("h1 [title='Click to edit']").click
    page.locator("h1 .editing").wait_for(state: 'visible', timeout: 5000)
    expect(page.get_by_role('button', name: 'Cancel')).to be_visible

    # Blur without making changes (click on navbar which is not editable)
    page.locator("nav.navbar").click

    # Editor should auto-cancel and return to display mode
    page.locator("h1 .editing").wait_for(state: 'hidden', timeout: 5000)
    expect(page.locator("h1").get_by_role('button', name: 'Cancel').count).to eq(0)
    expect(page.get_by_text(original_title)).to be_visible
  end

  scenario "Estimation title editor does NOT auto-cancel on blur with changes", :playwright do
    original_title = estimation.title
    new_title = "Modified Title"
    expect(page.get_by_text(original_title)).to be_visible

    # Click to open editor (scope to h1 to avoid matching estimation_item titles)
    page.locator("h1 [title='Click to edit']").click
    page.locator("h1 .editing").wait_for(state: 'visible', timeout: 5000)

    # Make a change
    page.locator("h1 input[type='text']").fill(new_title)

    # Blur with changes (click on navbar which is not editable)
    page.locator("nav.navbar").click

    # Editor should remain open because there are unsaved changes
    expect(page.locator("h1").get_by_role('button', name: 'Cancel')).to be_visible
    expect(page.locator("h1 .editing")).to be_visible

    # Cancel to clean up
    page.locator("h1").get_by_role('button', name: 'Cancel').click
    page.locator("h1 .editing").wait_for(state: 'hidden', timeout: 5000)
  end

  scenario "Estimation item title editor auto-cancels on blur without changes", :playwright do
    original_title = estimation_item.title
    expect(page.get_by_text(original_title)).to be_visible

    # Click to open editor
    page.get_by_title('Click to edit').filter(hasText: original_title).click
    page.locator(".editing").wait_for(state: 'visible', timeout: 5000)
    expect(page.get_by_role('button', name: 'Cancel')).to be_visible

    # Blur without making changes (click on navbar which is not editable)
    page.locator("nav.navbar").click

    # Editor should auto-cancel and return to display mode
    page.locator(".editing").wait_for(state: 'hidden', timeout: 5000)
    expect(page.get_by_role('button', name: 'Cancel').count).to eq(0)
    expect(page.get_by_text(original_title)).to be_visible
  end

  scenario "Estimation item value editor auto-cancels on blur without changes", :playwright do
    original_value = estimation_item.value
    expect(page.locator("table [title='Click to edit']").filter(hasText: original_value.to_s).first).to be_visible

    # Click to open editor (scope to table to target estimation_item, not estimation title)
    page.locator("table [title='Click to edit']").filter(hasText: original_value.to_s).first.click
    page.locator("table .editing").wait_for(state: 'visible', timeout: 5000)
    expect(page.get_by_role('button', name: 'Cancel')).to be_visible

    # Blur without making changes (click on navbar which is not editable)
    page.locator("nav.navbar").click

    # Editor should auto-cancel and return to display mode
    page.locator("table .editing").wait_for(state: 'hidden', timeout: 5000)
    # Note: There may be Cancel buttons from other editable fields in the table, check that none are in editing state
    expect(page.locator("table .editing").count).to eq(0)
    expect(page.locator("table [title='Click to edit']").filter(hasText: original_value.to_s).first).to be_visible
  end

  scenario "Save button works despite blur event", :playwright do
    original_title = estimation.title
    new_title = "New Title Via Save"
    expect(page.get_by_text(original_title)).to be_visible

    # Click to open editor (scope to h1 to avoid matching estimation_item titles)
    page.locator("h1 [title='Click to edit']").click
    page.locator("h1 .editing").wait_for(state: 'visible', timeout: 5000)

    # Change the value
    page.locator("h1 input[type='text']").fill(new_title)

    # Click Save button (this will trigger blur, but should complete the save)
    page.locator("h1").get_by_role('button', name: 'Save').click

    # Wait for Turbo Stream response and editing state to close
    page.locator("h1 .editing").wait_for(state: 'hidden', timeout: 5000)

    # Verify the new title is saved and displayed
    expect(page.get_by_text(new_title)).to be_visible
    expect(page.get_by_text(original_title).count).to eq(0)

    # Refresh and verify the change was persisted
    visit estimation_path(estimation)
    expect(page.get_by_text(new_title)).to be_visible
    expect(page.get_by_text(original_title).count).to eq(0)
  end

  scenario "Cancel button works despite blur event", :playwright do
    original_title = estimation.title
    new_title = "Title That Should Not Be Saved"
    expect(page.get_by_text(original_title)).to be_visible

    # Click to open editor (scope to h1 to avoid matching estimation_item titles)
    page.locator("h1 [title='Click to edit']").click
    page.locator("h1 .editing").wait_for(state: 'visible', timeout: 5000)

    # Change the value
    page.locator("h1 input[type='text']").fill(new_title)

    # Click Cancel button (this will trigger blur, but should complete the cancel)
    page.locator("h1").get_by_role('button', name: 'Cancel').click

    # Wait for editing state to close
    page.locator("h1 .editing").wait_for(state: 'hidden', timeout: 5000)

    # Verify the original title is still displayed (change was not saved)
    expect(page.get_by_text(original_title)).to be_visible
    expect(page.get_by_text(new_title).count).to eq(0)

    # Refresh and verify the change was not persisted
    visit estimation_path(estimation)
    expect(page.get_by_text(original_title)).to be_visible
    expect(page.get_by_text(new_title).count).to eq(0)
  end

  scenario "Auto-cancel resets input value to original", :playwright do
    original_title = estimation.title
    new_title = "Temporary Change"
    expect(page.get_by_text(original_title)).to be_visible

    # Click to open editor (scope to h1 to avoid matching estimation_item titles)
    page.locator("h1 [title='Click to edit']").click
    page.locator("h1 .editing").wait_for(state: 'visible', timeout: 5000)

    # Make a change
    page.locator("h1 input[type='text']").fill(new_title)

    # Press ESC to cancel (which should reset the value)
    page.locator("h1 input[type='text']").press('Escape')

    # Wait for editing state to close
    page.locator("h1 .editing").wait_for(state: 'hidden', timeout: 5000)

    # Open editor again
    page.locator("h1 [title='Click to edit']").click
    page.locator("h1 .editing").wait_for(state: 'visible', timeout: 5000)

    # Verify input has original value (was properly reset on cancel)
    expect(page.locator("h1 input[type='text']").input_value).to eq(original_title)

    # Now blur without changes - should auto-cancel (click on navbar which is not editable)
    page.locator("nav.navbar").click

    # Editor should auto-cancel
    page.locator("h1 .editing").wait_for(state: 'hidden', timeout: 5000)
    expect(page.get_by_text(original_title)).to be_visible
  end
end
