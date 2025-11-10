require 'rails_helper'

feature "EstimationItemOrdering", :type => :feature do
  let(:user) { FactoryBot.create(:user_with_estimations) }
  let(:estimation) { user.estimations.first }

  before(:each) do
    login_as user
  end

  # Playwright enables drag-and-drop testing that was previously incompatible with Capybara
  scenario 'EstimationItems can be reordered via drag and drop and order persists after refresh', :playwright do
    # Create estimation items with specific orders
    item1 = FactoryBot.create(:estimation_item, estimation: estimation, title: 'First Item', value: 10, order: 1.0)
    item2 = FactoryBot.create(:estimation_item, estimation: estimation, title: 'Second Item', value: 20, order: 2.0)
    item3 = FactoryBot.create(:estimation_item, estimation: estimation, title: 'Third Item', value: 30, order: 3.0)

    visit estimation_path(estimation)

    # Verify initial order
    expect(page.locator('.estimation-items-index tbody tr').nth(0).inner_text).to include('First Item')
    expect(page.locator('.estimation-items-index tbody tr').nth(1).inner_text).to include('Second Item')
    expect(page.locator('.estimation-items-index tbody tr').nth(2).inner_text).to include('Third Item')

    # Check that drag handles are present
    expect(page.locator('.drag-handle').count).to eq(3)

    # Drag the third item to the first item's position using jQuery UI Sortable
    # For jQuery UI Sortable, we need to drag to a position between items
    third_item_drag_handle = page.locator("tr:has-text('Third Item') .drag-handle")
    second_item = page.locator("tr:has-text('Second Item')")

    # Drag third item to second item's position (will move third between first and second)
    third_item_drag_handle.drag_to(second_item)

    # Wait for AJAX to complete
    page.wait_for_timeout(1000)

    # After dragging third to second's position, the order should be: First, Third, Second
    # (because jQuery UI Sortable places the element before the target)
    expect(page.locator('.estimation-items-index tbody tr').nth(0).inner_text).to include('First Item')
    expect(page.locator('.estimation-items-index tbody tr').nth(1).inner_text).to include('Third Item')
    expect(page.locator('.estimation-items-index tbody tr').nth(2).inner_text).to include('Second Item')

    # Refresh the page to verify order persists
    visit estimation_path(estimation)

    # Verify the order is still the same after refresh
    expect(page.locator('.estimation-items-index tbody tr').nth(0).inner_text).to include('First Item')
    expect(page.locator('.estimation-items-index tbody tr').nth(1).inner_text).to include('Third Item')
    expect(page.locator('.estimation-items-index tbody tr').nth(2).inner_text).to include('Second Item')
  end

  scenario 'Creating items via UI maintains correct order after refresh', :playwright do
    visit estimation_path(estimation)

    # Add first item
    page.locator('#estimation_item_value').fill('10')
    page.locator('#estimation_item_title').fill('First Created Item')
    page.locator('#estimation_item_title').press('Enter')

    # Wait for first item to appear in the list
    page.locator("tr:has-text('First Created Item')").wait_for(state: 'visible', timeout: 5000)

    # Add second item
    page.locator('#estimation_item_value').fill('20')
    page.locator('#estimation_item_title').fill('Second Created Item')
    page.locator('#estimation_item_title').press('Enter')

    # Wait for second item to appear in the list
    page.locator("tr:has-text('Second Created Item')").wait_for(state: 'visible', timeout: 5000)

    # Verify both items are present
    expect(page.get_by_text('First Created Item')).to be_visible
    expect(page.get_by_text('Second Created Item')).to be_visible

    # Check order in UI
    expect(page.locator('.estimation-items-index tbody tr').nth(0).inner_text).to include('First Created Item')
    expect(page.locator('.estimation-items-index tbody tr').nth(1).inner_text).to include('Second Created Item')

    # Refresh the page
    visit estimation_path(estimation)

    # Verify items are still present and in correct order
    expect(page.locator('.estimation-items-index tbody tr').count).to eq(2)
    expect(page.locator('.estimation-items-index tbody tr').nth(0).inner_text).to include('First Created Item')
    expect(page.locator('.estimation-items-index tbody tr').nth(1).inner_text).to include('Second Created Item')
  end
end
