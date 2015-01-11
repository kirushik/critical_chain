require 'rails_helper'

feature "AdditionOfEstimationsAndItems", :type => :feature do
  let(:user) { FactoryGirl.create(:user_with_nonempty_estimations) }
  let(:estimation) {user.estimations.first}

  let(:new_estimation_title) {'Kapandlya'}
  let(:new_estimation_value) {7}

  before(:each) do
    login_as user
    visit estimation_path(estimation)
  end

  scenario 'I can modify the estimation item title', :js do
    expect(page).not_to have_text new_estimation_title

    page.find('span.editable', text: estimation.estimation_items.first.title).click
    expect(page).to have_css('.editable-inline')

    page.find('.editable-inline .editable-input input').set new_estimation_title
    page.find('.editable-inline .editable-submit').click

    wait_for_ajax

    expect(page).to have_text new_estimation_title

    visit current_path
    expect(page).to have_text new_estimation_title
  end

  scenario 'I can modify estimation item value', :js do
    expect(page).not_to have_text new_estimation_value

    page.find('span.editable', text: estimation.estimation_items.first.value).click
    page.find('.editable-inline .editable-input input').set new_estimation_value
    page.find('.editable-inline .editable-submit').click

    wait_for_ajax

    expect(page).to have_text new_estimation_value
    expect(page).to have_text '7 + 7 = 14'
  end
end