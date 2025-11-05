require "rails_helper"

feature "EstimationTitleEditing", :type => :feature do
  let(:user) { FactoryBot.create(:user_with_nonempty_estimations) }
  let(:estimation) { user.estimations.first }
  let(:new_title) { "My New Estimation Title" }

  before(:each) do
    login_as user
    visit estimation_path(estimation)
  end

  scenario "I can see the estimation title on the page", :js do
    expect(page).to have_text estimation.title
  end

  scenario "I can modify the estimation title", :js do
    expect(page).to have_text estimation.title
    expect(page).to have_no_text new_title

    page.find("h1 span.editable.title", text: estimation.title).click
    expect(page).to have_css(".editable-inline")

    page.find(".editable-inline .editable-input input").set new_title
    page.find(".editable-inline .editable-submit").click

    wait_for_ajax

    expect(page).to have_text new_title
    expect(page).to have_no_text estimation.title

    visit current_path
    expect(page).to have_text new_title
  end

  scenario "I can cancel editing the estimation title", :js do
    original_title = estimation.title

    page.find("h1 span.editable.title", text: estimation.title).click
    expect(page).to have_css(".editable-inline")

    page.find(".editable-inline .editable-input input").set new_title
    page.find(".editable-inline .editable-cancel").click

    expect(page).to have_text original_title
    expect(page).to have_no_text new_title

    visit current_path
    expect(page).to have_text original_title
  end
end
