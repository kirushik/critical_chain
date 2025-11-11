require 'rails_helper'

feature "AdditionOfEstimationsAndItems", :type => :feature do
  let(:user) { FactoryBot.create(:user_with_estimations) }
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

  scenario 'I can add estimation items on the corresponding page', :playwright do
    visit estimation_path(estimation)

    expect(page.get_by_text(new_title).count).to eq(0)

    page.locator('#estimation_item_value').fill('7')
    page.locator('#estimation_item_title').fill(new_title)
    page.locator('#estimation_item_title').press('Enter')

    # Wait for the new item to appear in the table
    page.locator("tr:has-text('#{new_title}')").wait_for(state: 'visible', timeout: 5000)

    expect(page.locator('#estimation_item_value').input_value).not_to eq('7')
    expect(page.locator('#estimation_item_title').input_value).not_to eq(new_title)

    expect(page.get_by_text(new_title)).to be_visible
  end
end
