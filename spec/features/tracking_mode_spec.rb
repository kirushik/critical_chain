require 'rails_helper'

feature "Tracking mode", :type => :feature do
  let(:user) { FactoryBot.create(:user_with_nonempty_estimations, n: 2) }
  let(:estimation) { user.estimations.first }
  let(:tracking_mode_estimation) { FactoryBot.create(:estimation_with_items, tracking_mode: true, user: user) }
  let(:first_estimation_item) { tracking_mode_estimation.estimation_items.first }

  before(:each) do
    login_as user
  end

  scenario 'I can enter tracking mode', :playwright do
    visit estimation_path(estimation)

    expect(page.locator('.toggle-tracking .fa-toggle-off')).to be_visible
    expect(page.locator('.toggle-tracking .fa-toggle-on').count).to eq(0)

    page.locator('.toggle-tracking').click

    # Wait for the toggle to switch
    page.locator('.toggle-tracking .fa-toggle-on').wait_for(state: 'visible', timeout: 5000)

    expect(page.locator('.toggle-tracking .fa-toggle-on')).to be_visible
    expect(page.locator('.toggle-tracking .fa-toggle-off').count).to eq(0)
  end

  scenario 'I can enter value for an item of tracking-mode estimation', :playwright do
    visit estimation_path(tracking_mode_estimation)

    # Click on the first actual_value field in the table (not the title)
    page.locator("table [title='Click to edit']").first.click

    # Wait for editing state to activate
    page.locator(".editing").wait_for(state: 'visible', timeout: 5000)

    # Fill the number input
    page.locator(".editing input[type='number']").fill('11179')
    page.get_by_role('button', name: 'Save').click

    # Wait for the display to return - wait for the .editing class to disappear
    page.locator(".editing").wait_for(state: 'hidden', timeout: 5000)

    # Check that actual_sum is updated (text is split across elements, so check the sum directly)
    expect(page.locator('#actual_sum').text_content).to eq('11179.0')
    expect(page.get_by_text('out of')).to be_visible
    expect(page.locator('#total').text_content).to eq(tracking_mode_estimation.decorate.total.to_s)
  end

  scenario 'I can see buffer consumption in tracking mode' do
    first_estimation_item.update_attribute(:actual_value, 1.5*first_estimation_item.value)
    visit estimation_path(tracking_mode_estimation)
    expect(page).to have_text("50%")
  end

  scenario 'Buffer consumption in tracking mode is recalculated via AJAX', :playwright do
    visit estimation_path(tracking_mode_estimation)

    expect(page.get_by_text("50%").count).to eq(0)

    # Click on the first actual_value field in the table
    page.locator("table [title='Click to edit']").first.click

    # Wait for editing state to activate
    page.locator(".editing").wait_for(state: 'visible', timeout: 5000)

    page.locator(".editing input[type='number']").fill((1.9*first_estimation_item.value).to_s)
    page.get_by_role('button', name: 'Save').click

    # Wait for the display to return - wait for the .editing class to disappear
    page.locator(".editing").wait_for(state: 'hidden', timeout: 5000)

    expect(page.get_by_text("90%")).to be_visible
    expect(page.locator('#buffer_health.has-text-warning')).to be_visible
  end
end
