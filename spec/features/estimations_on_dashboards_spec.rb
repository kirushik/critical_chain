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
    estimation.estimation_items.each do |item|
      expect(page).to have_text(item.value)
      expect(page).to have_text(item.title)
    end
  end

  scenario 'I can add an estimation' do
    visit root_path

    fill_in 'estimation_title', with: 'Azaza zuzu'
    click_button 'Create estimation'

    expect(page.title).to start_with('Azaza zuzu')
  end
end
