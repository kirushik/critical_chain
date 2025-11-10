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

    page.locator("h1 span.editable.title:has-text('#{estimation.title}')").click
    expect(page.locator(".editable-inline")).to be_visible

    page.locator(".editable-inline .editable-input input").fill(new_title)
    page.locator(".editable-inline .editable-submit").click

    # Wait for the editor to close after save
    page.locator(".editable-inline").wait_for(state: 'hidden', timeout: 5000)

    expect(page.get_by_text(new_title)).to be_visible
    expect(page.get_by_text(estimation.title).count).to eq(0)

    visit estimation_path(estimation)
    expect(page.get_by_text(new_title)).to be_visible
  end

  scenario "I can cancel editing the estimation title", :playwright do
    original_title = estimation.title

    page.locator("h1 span.editable.title:has-text('#{estimation.title}')").click
    expect(page.locator(".editable-inline")).to be_visible

    page.locator(".editable-inline .editable-input input").fill(new_title)
    page.locator(".editable-inline .editable-cancel").click

    # Wait for the display element (span.editable.title) to become visible again after cancellation
    page.locator("h1 span.editable.title:has-text('#{original_title}')").wait_for(state: 'visible', timeout: 5000)

    expect(page.locator("h1 span.editable.title:has-text('#{original_title}')")).to be_visible
    expect(page.get_by_text(new_title).count).to eq(0)

    visit estimation_path(estimation)
    expect(page.locator("h1 span.editable.title:has-text('#{original_title}')")).to be_visible
  end
end
