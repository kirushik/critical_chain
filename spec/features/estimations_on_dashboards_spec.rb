require 'rails_helper'

feature "EstimationsOnDashboards", :type => :feature do

  let(:user) { FactoryGirl.create(:user_with_estimations) }
  before(:each) do
    login_as user
  end

  scenario 'I can open my estimations' do
    estimation = user.estimations.first

    visit root_path
    click_link(estimation.title)

    expect(page.title).to start_with(estimation.title)
  end
end
