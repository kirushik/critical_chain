require 'rails_helper'

feature "EstimationItemOrdering", :type => :feature do
  let(:user) { FactoryBot.create(:user_with_estimations) }
  let(:estimation) { user.estimations.first }

  before(:each) do
    login_as user
  end

  scenario 'EstimationItems can be reordered via drag and drop', :js do
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
    expect(page).to have_css('.fa-bars', count: 3)
  end

  scenario 'EstimationItems display in order specified by order field' do
    # Create items with specific order values
    item1 = FactoryBot.create(:estimation_item, estimation: estimation, title: 'Third by order', value: 10, order: 3.0)
    item2 = FactoryBot.create(:estimation_item, estimation: estimation, title: 'First by order', value: 20, order: 1.0)
    item3 = FactoryBot.create(:estimation_item, estimation: estimation, title: 'Second by order', value: 30, order: 2.0)

    visit estimation_path(estimation)

    # Verify items are displayed in order field order, not creation order
    items = page.all('.estimation-items-index tbody tr')
    expect(items[0]).to have_text('First by order')
    expect(items[1]).to have_text('Second by order')
    expect(items[2]).to have_text('Third by order')
  end

  scenario 'New EstimationItems get assigned appropriate order values' do
    # Create first item
    item1 = FactoryBot.create(:estimation_item, estimation: estimation, title: 'First Item', value: 10)
    
    # Create second item - should get a higher order value
    item2 = FactoryBot.create(:estimation_item, estimation: estimation, title: 'Second Item', value: 20)

    expect(item1.order).to be > 0
    expect(item2.order).to be > item1.order
  end
end
