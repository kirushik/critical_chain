require 'rails_helper'

feature "AdditionOfEstimationsAndItems", :type => :feature do
  let(:user) { FactoryGirl.create(:user_with_estimations) }
  let(:estimation) {user.estimations.first}

  let(:new_title) {'Akukaracha'}

  before(:each) do
    login_as user
  end

  scenario 'I can add an estimation' do
    visit root_path

    fill_in 'estimation_title', with: 'Azaza zuzu'
    click_button 'Create estimation'

    expect(page.title).to start_with('Azaza zuzu')
  end

  scenario 'I can add estimation items on the corresponding page', :js do
    visit estimation_path(estimation)

    expect(page).not_to have_selector("input[value=\"#{new_title}\"]")

    fill_in 'estimation_item_value', with: 7
    fill_in 'estimation_item_title', with: new_title
    click_button 'Add estimation item'

    wait_for_ajax

    expect(find_field('estimation_item_value').value).not_to eq('7')
    expect(find_field('estimation_item_title').value).not_to eq(new_title)

    expect(page).to have_selector("input[value=\"#{new_title}\"]")
  end
end
