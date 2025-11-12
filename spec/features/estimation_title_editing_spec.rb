require "rails_helper"

feature "EstimationTitleEditing", :type => :feature do
  let(:user) { FactoryBot.create(:user_with_nonempty_estimations) }
  let(:estimation) { user.estimations.first }
  let(:new_title) { "My New Estimation Title" }

  before(:each) do
    login_as user
    visit estimation_path(estimation)
  end

  scenario "I can see the estimation title on the page", :playwright do
    expect(page.get_by_text(estimation.title)).to be_visible
  end

  scenario "I can modify the estimation title", :playwright do
    expect(page.get_by_text(estimation.title)).to be_visible
    expect(page.get_by_text(new_title).count).to eq(0)

    # Click on the title to edit
    page.get_by_title('Click to edit').filter(hasText: estimation.title).click

    # Form should now be visible - check for Save button
    expect(page.get_by_role('button', name: 'Save')).to be_visible

    # Fill in the new title
    page.locator("h1 input[type='text']").fill(new_title)
    page.get_by_role('button', name: 'Save').click

    # Wait for the form to close and display to return
    page.get_by_title('Click to edit').filter(hasText: new_title).wait_for(state: 'visible', timeout: 5000)

    expect(page.get_by_text(new_title)).to be_visible
    expect(page.get_by_text(estimation.title).count).to eq(0)

    visit estimation_path(estimation)
    expect(page.get_by_text(new_title)).to be_visible
  end

  scenario "I can cancel editing the estimation title", :playwright do
    original_title = estimation.title

    # Click to edit
    page.get_by_title('Click to edit').filter(hasText: original_title).click

    # Form should be visible
    expect(page.get_by_role('button', name: 'Cancel')).to be_visible

    # Change the value
    page.locator("h1 input[type='text']").fill(new_title)

    # Click cancel
    page.get_by_role('button', name: 'Cancel').click

    # Wait for the display to become visible again with original title
    page.get_by_title('Click to edit').filter(hasText: original_title).wait_for(state: 'visible', timeout: 5000)

    expect(page.get_by_text(original_title)).to be_visible
    expect(page.get_by_text(new_title).count).to eq(0)

    visit estimation_path(estimation)
    expect(page.get_by_text(original_title)).to be_visible
  end
end
