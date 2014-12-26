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

  scenario 'should be recalculated with AJAX'
end
