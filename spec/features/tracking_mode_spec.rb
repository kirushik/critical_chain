require 'rails_helper'

feature "Tracking mode", :type => :feature do
  let(:user) { FactoryGirl.create(:user_with_nonempty_estimations, n: 2) }
  let(:estimation) { user.estimations.first }
  let(:tracking_mode_estimation) { FactoryGirl.create(:estimation_with_items, tracking_mode: true, user: user) }

  before(:each) do
    login_as user
  end

  scenario 'I can enter tracking mode', :js do
    visit estimation_path(estimation)

    expect(page).to have_css('.toggle-tracking .fa-toggle-off')
    expect(page).to have_no_css('.toggle-tracking .fa-toggle-on')

    find('.toggle-tracking').click

    expect(page).to have_css('.toggle-tracking .fa-toggle-on')
    expect(page).to have_no_css('.toggle-tracking .fa-toggle-off')
  end

  scenario 'I can enter value for an item of tracking-mode estimation', :js do
    visit estimation_path(tracking_mode_estimation)

    page.first('span.editable.actual_value').click
    page.find('.editable-inline .editable-input input').set 10
    page.find('.editable-inline .editable-submit').click
  end
end