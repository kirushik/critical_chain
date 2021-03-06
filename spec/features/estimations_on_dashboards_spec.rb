require 'rails_helper'

feature "EstimationsOnDashboards", :type => :feature do

  let(:user) { FactoryBot.create(:user_with_estimations) }
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

  scenario 'won\'t show me other people\'s estimations' do
    other_user = FactoryBot.create(:user_with_estimations)

    visit root_path

    user.estimations.each do |e|
      expect(page).to have_text(e.title)
    end

    other_user.estimations.each do |e|
      expect(page).not_to have_text(e.title)
    end
  end
end
