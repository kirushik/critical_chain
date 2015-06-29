require 'rails_helper'

feature "Tracking mode", :type => :feature do
  let(:user) { FactoryGirl.create(:user_with_nonempty_estimations, n: 2) }
  let(:estimation) { user.estimations.first }

  before(:each) do
    login_as user
    visit estimation_path(estimation)
  end

  scenario 'I can enter tracking mode', :js do
    expect(page).to have_css('.toggle-tracking .fa-toggle-off')
    expect(page).to have_no_css('.toggle-tracking .fa-toggle-on')

    find('.toggle-tracking').click

    expect(page).to have_css('.toggle-tracking .fa-toggle-on')
    expect(page).to have_no_css('.toggle-tracking .fa-toggle-off')
  end
end