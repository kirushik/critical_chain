require 'rails_helper'

feature "Estimated values", :type => :feature do
  let(:user) { FactoryGirl.create(:user_with_estimations) }
  let(:estimation) {user.estimations.first}

  before(:each) do
    login_as user
  end

  scenario 'should be calculated on the estimation page' do
    2.times do
      estimation.estimation_items << FactoryGirl.create(:estimation_item, value: 2)
    end

    visit estimation_path(estimation)

    expect(page).to have_text(2.83)
  end

  scenario 'should be recalculated with AJAX', :js do
    visit estimation_path(estimation)

    expect(page).to have_text(0)

    fill_in 'estimation_item_title', with: 'A'
    fill_in 'estimation_item_value', with: 1
    click_button 'Add estimation item'

    fill_in 'estimation_item_title', with: 'B'
    fill_in 'estimation_item_value', with: 7
    click_button 'Add estimation item'

    wait_for_ajax

    # FIXME Flickering test!
    expect(page).to have_text(8)
    expect(page).to have_text(5.66)
    expect(page).to have_text(13.7)
  end
end
