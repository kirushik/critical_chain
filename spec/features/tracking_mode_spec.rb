require 'rails_helper'

feature "Tracking mode", :type => :feature do
  let(:user) { FactoryGirl.create(:user_with_nonempty_estimations, n: 2) }
  let(:estimation) { user.estimations.first }
  let(:tracking_mode_estimation) { FactoryGirl.create(:estimation_with_items, tracking_mode: true, user: user) }
  let(:first_estimation_item) { tracking_mode_estimation.estimation_items.first }

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
    page.find('.editable-inline .editable-input input').set 11179
    page.find('.editable-inline .editable-submit').click

    expect(page).to have_text "11179 out of #{estimation.decorate.total}"
  end

  scenario 'I can see buffer consumption in tracking mode' do
    first_estimation_item.update_attribute(:actual_value, 1.5*first_estimation_item.value)
    visit estimation_path(tracking_mode_estimation)
    expect(page).to have_text("50%")
  end

  scenario 'Buffer consumption in tracking mode is recalculated via AJAX', :js do
    visit estimation_path(tracking_mode_estimation)

    expect(page).to have_no_text("50%")

    page.find('span.editable.actual_value').click
    page.find('.editable-inline .editable-input input').set 1.5*first_estimation_item.value
    page.find('.editable-inline .editable-submit').click

    expect(page).to have_text("50%")
  end
end
