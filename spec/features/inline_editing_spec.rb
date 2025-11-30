require "rails_helper"

feature "AdditionOfEstimationsAndItems", :type => :feature do
  let(:user) { FactoryBot.create(:user_with_nonempty_estimations) }
  let(:estimation) { user.estimations.first }

  let(:new_estimation_title) { "Kapandlya" }
  let(:new_estimation_value) { 7 }

  let(:old_estimation_value) { estimation.estimation_items.first.value }

  before(:each) do
    login_as user
    visit estimation_path(estimation)
  end

  scenario "I can modify the estimation item title", :playwright do
    expect(page.get_by_text(new_estimation_title).count).to eq(0)

    # Click on the title to edit
    page.get_by_title('Click to edit').filter(hasText: estimation.estimation_items.first.title).click

    # Form should be visible - check for Save button
    expect(page.get_by_role('button', name: 'Save')).to be_visible

    # Fill in new title - scope to the .editing field
    page.locator(".editing input[type='text'][name*='[title]']").fill(new_estimation_title)
    page.get_by_role('button', name: 'Save').click

    # Wait for the display to return with new title
    page.get_by_title('Click to edit').filter(hasText: new_estimation_title).wait_for(state: 'visible', timeout: 5000)

    expect(page.get_by_text(new_estimation_title)).to be_visible

    visit estimation_path(estimation)
    expect(page.get_by_text(new_estimation_title)).to be_visible
  end

  scenario "I can modify estimation item value", :playwright do
    expect(page.get_by_text(new_estimation_value.to_s, exact: true).count).to eq(0)

    # Click on the value to edit
    page.get_by_title('Click to edit').filter(hasText: estimation.estimation_items.first.value.to_s).click

    # Wait for the editing state to be active and form to be visible
    page.locator(".editing").wait_for(state: 'visible', timeout: 5000)

    # Fill in new value - the input exists with correct type,selector without type is more reliable
    page.locator(".editing input[name*='[value]']").fill(new_estimation_value.to_s)
    page.get_by_role('button', name: 'Save').click

    # Wait for the display to return with new value
    page.get_by_title('Click to edit').filter(hasText: new_estimation_value.to_s).wait_for(state: 'visible', timeout: 5000)

    # Verify the summary values updated correctly (7 sum + 7 buffer = 14 total)
    expect(page.locator("#sum").text_content).to eq('7')
    expect(page.locator("#buffer").text_content).to eq('7')
    expect(page.locator("#total").text_content).to eq('14')
  end

  scenario "AJAX-added items are editable", :playwright do
    initial_count = estimation.estimation_items.count

    page.locator("#estimation_item_value").fill(new_estimation_value.to_s)
    page.locator("#estimation_item_title").fill(new_estimation_title)
    # Submit the form - press Enter or find submit button
    page.locator("#estimation_item_title").press("Enter")

    # Wait for the new item to be added via AJAX - check for new editable field
    page.get_by_title('Click to edit').filter(hasText: new_estimation_title).wait_for(state: 'visible', timeout: 5000)

    # Verify all editable fields are present (each has "Click to edit" title)
    expect(page.locator("table.estimation-items-index [title='Click to edit']").count).to eq(estimation.estimation_items.count * 3) # title, value, quantity

    # Click on the last item's value to verify it's editable
    page.get_by_title('Click to edit').filter(hasText: estimation.estimation_items.last.value.to_s).click

    # Verify form is visible
    expect(page.get_by_role('button', name: 'Save')).to be_visible
  end

  scenario "I can mark estimation item as fixed", :playwright do
    page.locator(".fixed-button").click

    # Wait for AJAX to complete - the thumbtack icon should appear when item is fixed
    page.locator(".fa-thumbtack").wait_for(state: 'visible', timeout: 5000)

    # Verify the summary values updated correctly
    expect(page.locator("#sum").text_content).to eq(old_estimation_value.to_s)
    expect(page.locator("#buffer").text_content).to eq('0')
    expect(page.locator("#total").text_content).to eq(old_estimation_value.to_s)
  end

  scenario "I can set the number for a batch", :playwright do
    # Click on quantity to edit (should be "1" initially)
    page.get_by_title('Click to edit').filter(hasText: /^1$/).first.click

    # Wait for editing state to activate
    page.locator(".editing").wait_for(state: 'visible', timeout: 5000)

    # Fill in new quantity - scope to the .editing field
    page.locator(".editing input[name*='[quantity]']").fill("4")
    page.get_by_role('button', name: 'Save').click

    # Wait for display to return
    page.get_by_title('Click to edit').filter(hasText: '4').wait_for(state: 'visible', timeout: 5000)

    # Verify the summary values updated correctly (4*10=40 sum, 20 buffer, 60 total)
    expect(page.locator("#sum").text_content).to eq((4 * old_estimation_value).to_s)
    expect(page.locator("#buffer").text_content).to eq((2 * old_estimation_value).to_s)
    expect(page.locator("#total").text_content).to eq((6 * old_estimation_value).to_s)
  end

  scenario "I can see updated total when estimation or count has been changed", :playwright do
    # Click on quantity to edit
    page.get_by_title('Click to edit').filter(hasText: /^1$/).first.click
    page.locator(".editing input[name*='[quantity]']").fill("20")
    page.get_by_role('button', name: 'Save').click

    # Wait for display to return
    page.get_by_title('Click to edit').filter(hasText: '20').wait_for(state: 'visible', timeout: 5000)

    # Now edit the value
    page.get_by_title('Click to edit').filter(hasText: old_estimation_value.to_s).click
    page.locator(".editing input[name*='[value]']").fill("17")
    page.get_by_role('button', name: 'Save').click

    # Wait for display to return
    page.get_by_title('Click to edit').filter(hasText: '17').wait_for(state: 'visible', timeout: 5000)

    # Verify the total in the item row (20*17=340)
    expect(page.locator(".calculation-group .total").text_content).to eq("340")
  end
end
