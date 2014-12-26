require 'rails_helper'

feature "UserPermissions", :type => :feature do
  scenario 'I shouldn\'t be allowed to view other people estimations' do
    user_a = FactoryGirl.create(:user)
    user_b = FactoryGirl.create(:user_with_estimations)
    others_estimation = user_b.estimations.first

    login_as user_a

    visit estimation_path(others_estimation)
    expect(page.status_code).to be(403)
  end
end
