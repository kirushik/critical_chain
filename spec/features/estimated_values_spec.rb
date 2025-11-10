require 'rails_helper'

feature "Estimated values", :type => :feature do
  let(:user) { FactoryBot.create(:user_with_estimations) }
  let(:estimation) {user.estimations.first}

  before(:each) do
    login_as user
  end

  scenario 'should be calculated on the estimation page' do
    2.times do
      estimation.estimation_items << FactoryBot.create(:estimation_item, value: 2)
    end

    visit estimation_path(estimation)

    expect(page).to have_text(2.83)
  end

  scenario 'should be recalculated with AJAX', :playwright do
    visit estimation_path(estimation)

    expect(page.locator('#total').inner_text.to_f).to eq(0)

    page.locator('#estimation_item_value').fill('1')
    page.locator('#estimation_item_value').press('Enter')

    # Wait for first item to be added
    page.wait_for_timeout(500)

    page.locator('#estimation_item_value').fill('7')
    page.locator('#estimation_item_value').press('Enter')

    # Wait for second item to be added and calculations to update
    page.locator("#total:has-text('13.7')").wait_for(state: 'visible', timeout: 5000)

    expect(page.locator("#sum:has-text('8')").first).to be_visible
    expect(page.locator("#buffer:has-text('5.66')").first).to be_visible
    expect(page.locator("#total:has-text('13.7')").first).to be_visible
  end
end
