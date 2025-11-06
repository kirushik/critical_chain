require 'rails_helper'

feature "EstimationItemOrdering", :type => :feature do
  let(:user) { FactoryBot.create(:user_with_estimations) }
  let(:estimation) { user.estimations.first }

  before(:each) do
    login_as user
  end

  scenario 'EstimationItems can be reordered via drag and drop and order persists after refresh', :js do
    # Create estimation items with specific orders
    item1 = FactoryBot.create(:estimation_item, estimation: estimation, title: 'First Item', value: 10, order: 1.0)
    item2 = FactoryBot.create(:estimation_item, estimation: estimation, title: 'Second Item', value: 20, order: 2.0)
    item3 = FactoryBot.create(:estimation_item, estimation: estimation, title: 'Third Item', value: 30, order: 3.0)

    visit estimation_path(estimation)

    # Verify initial order
    items = page.all('.estimation-items-index tbody tr')
    expect(items[0]).to have_text('First Item')
    expect(items[1]).to have_text('Second Item')
    expect(items[2]).to have_text('Third Item')

    # Check that drag handles are present
    expect(page).to have_css('.drag-handle', count: 3)

    # Drag the third item to the first position
    third_item = page.find('tr', text: 'Third Item')
    first_item = page.find('tr', text: 'First Item')
    third_item.drag_to(first_item)

    wait_for_ajax

    # Verify the order changed in the UI
    items = page.all('.estimation-items-index tbody tr')
    expect(items[0]).to have_text('Third Item')
    expect(items[1]).to have_text('First Item')
    expect(items[2]).to have_text('Second Item')

    # Refresh the page to verify order persists
    visit estimation_path(estimation)

    # Verify the order is still the same after refresh
    items = page.all('.estimation-items-index tbody tr')
    expect(items[0]).to have_text('Third Item')
    expect(items[1]).to have_text('First Item')
    expect(items[2]).to have_text('Second Item')
  end

  scenario 'Creating items via UI maintains correct order after refresh', :js do
    visit estimation_path(estimation)

    # Add first item
    fill_in 'estimation_item_value', with: 10
    fill_in 'estimation_item_title', with: 'First Created Item'
    click_button 'Add estimation item'

    wait_for_ajax

    # Add second item
    fill_in 'estimation_item_value', with: 20
    fill_in 'estimation_item_title', with: 'Second Created Item'
    click_button 'Add estimation item'

    wait_for_ajax

    # Verify both items are present
    expect(page).to have_text('First Created Item')
    expect(page).to have_text('Second Created Item')

    # Check order in UI
    items = page.all('.estimation-items-index tbody tr')
    expect(items[0]).to have_text('First Created Item')
    expect(items[1]).to have_text('Second Created Item')

    # Refresh the page
    visit estimation_path(estimation)

    # Verify items are still present and in correct order
    items = page.all('.estimation-items-index tbody tr')
    expect(items.length).to eq(2)
    expect(items[0]).to have_text('First Created Item')
    expect(items[1]).to have_text('Second Created Item')
  end
end
