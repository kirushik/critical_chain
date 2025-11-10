require "rails_helper"

feature "AdditionOfEstimationsAndItems", :type => :feature do
  let(:user) { FactoryBot.create(:user_with_nonempty_estimations) }
  let(:estimation) { user.estimations.first }

  let(:new_estimation_title) { "Kapandlya" }
  let(:new_estimation_value) { 7 }

  let(:old_estimation_value) { estimation.estimation_items.first.value }

  before(:each) do
    login_as user
    visit estimation_path(estimation)
  end

  scenario "I can modify the estimation item title", :playwright do
    expect(page.get_by_text(new_estimation_title).count).to eq(0)

    page.locator("span.editable.title:has-text('#{estimation.estimation_items.first.title}')").click
    page.locator(".editable-inline").wait_for(state: 'visible')

    page.locator(".editable-inline .editable-input input").fill(new_estimation_title)
    page.locator(".editable-inline .editable-submit").click

    # Wait for the AJAX request to complete and the inline editor to disappear
    page.locator(".editable-inline").wait_for(state: 'hidden')

    expect(page.get_by_text(new_estimation_title)).to be_visible

    visit estimation_path(estimation)
    expect(page.get_by_text(new_estimation_title)).to be_visible
  end

  scenario "I can modify estimation item value", :playwright do
    expect(page.get_by_text(new_estimation_value.to_s, exact: true).count).to eq(0)

    page.locator("span.editable.value:has-text('#{estimation.estimation_items.first.value}')").click
    page.locator(".editable-inline .editable-input input").fill(new_estimation_value.to_s)
    page.locator(".editable-inline .editable-submit").click

    # Wait for the AJAX request to complete
    page.locator(".editable-inline").wait_for(state: 'hidden')

    expect(page.locator("span.editable.value:has-text('#{new_estimation_value}')").first).to be_visible
    expect(page.get_by_text("7 + 7 = 14")).to be_visible
  end

  scenario "AJAX-added items are editable", :playwright do
    initial_count = estimation.estimation_items.count

    page.locator("#estimation_item_value").fill(new_estimation_value.to_s)
    page.locator("#estimation_item_title").fill(new_estimation_title)
    # Submit the form - press Enter or find submit button
    page.locator("#estimation_item_title").press("Enter")

    # Wait for the new item to be added via AJAX by checking the count increased
    page.locator("table.estimation-items-index span.editable.value").nth(initial_count).wait_for(state: 'visible', timeout: 5000)

    # Verify all editable elements are present
    expect(page.locator("table.estimation-items-index span.editable.value").count).to eq(estimation.estimation_items.count)
    expect(page.locator("table.estimation-items-index span.editable.title").count).to eq(estimation.estimation_items.count)
    expect(page.locator("table.estimation-items-index span.editable.quantity").count).to eq(estimation.estimation_items.count)

    # Click on the last item's value
    page.locator("span.editable:has-text('#{estimation.estimation_items.last.value}')").click

    page.locator(".editable-inline").wait_for(state: 'visible')
  end

  scenario "I can mark estimation item as fixed", :playwright do
    page.locator(".toggle-fixed").click

    # Wait for AJAX to complete and the total to update
    page.get_by_text("#{old_estimation_value} + 0 = #{old_estimation_value}").wait_for(state: 'visible', timeout: 5000)

    expect(page.get_by_text("#{old_estimation_value} + 0 = #{old_estimation_value}")).to be_visible
  end

  scenario "I can set the number for a batch", :playwright do
    page.locator("span.editable.quantity").click
    page.locator(".editable-inline .editable-input input").fill("4")
    page.locator(".editable-inline .editable-submit").click

    page.locator(".editable-inline").wait_for(state: 'hidden')

    expect(page.get_by_text("#{4 * old_estimation_value} + #{2 * old_estimation_value} = #{6 * old_estimation_value}")).to be_visible
  end

  scenario "I can see updated total when estimation or count has been changed", :playwright do
    page.locator("span.editable.quantity").click
    page.locator(".editable-inline .editable-input input").fill("20")
    page.locator(".editable-inline .editable-submit").click

    page.locator(".editable-inline").wait_for(state: 'hidden')

    page.locator("span.editable.value").click
    page.locator(".editable-inline .editable-input input").fill("17")
    page.locator(".editable-inline .editable-submit").click

    page.locator(".editable-inline").wait_for(state: 'hidden')

    expect(page.get_by_text("= 340")).to be_visible
  end
end
