require 'rails_helper'

feature "AdditionOfEstimationsAndItems", :type => :feature do
  let(:user) { FactoryGirl.create(:user_with_estimations) }
  let(:estimation) {user.estimations.first}

  let(:new_title) {'Akukaracha'}

  before(:each) do
    login_as user
  end

  it 'should allow me to add estimations on the root page', :js do
    visit estimation_path(estimation)

    expect(page).not_to have_text(new_title)

    fill_in 'estimation_item_value', with: 7
    fill_in 'estimation_item_title', with: new_title
    click_button 'Add estimation'

    expect(page).to have_text(new_title)
  end
end
