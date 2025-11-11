require 'rails_helper'

feature "Deletions", :type => :feature do
  let(:user) { FactoryBot.create(:user_with_nonempty_estimations, n: 2) }
  let(:estimation) { user.estimations.first }
  let(:estimations_count) {user.estimations.size }

  let(:first_item) { estimation.estimation_items.first }
  let(:items_count) { estimation.estimation_items.size }

  before(:each) do
    login_as user
  end

  context "Items deletions" do
    it 'should be possible without AJAX' do
      visit estimation_path(estimation)

      buttons = page.all('button', :text => '×')
      expect(buttons.size).to eq(items_count)
      expect(page).to have_text(first_item.title)

      buttons.first.click

      expect(page.status_code).to eq(200)

      new_buttons = page.all('button', :text => '×')
      expect(new_buttons.size).to eq(items_count-1)
      expect(page).not_to have_text(first_item.title)
    end

    it 'should be possible with AJAX', :playwright do
      visit estimation_path(estimation)

      initial_button_count = page.locator("button:has-text('×')").count
      expect(initial_button_count).to eq(items_count)
      expect(page.get_by_text(first_item.title)).to be_visible

      # Set up dialog handler before clicking
      page.once('dialog', ->(dialog) { dialog.accept })
      page.locator("button:has-text('×')").first.click

      # Wait for the item to be removed from the DOM
      page.locator("button:has-text('×')").nth(items_count - 1).wait_for(state: 'hidden', timeout: 5000)

      expect(page.locator("button:has-text('×')").count).to eq(items_count - 1)
      expect(page.get_by_text(first_item.title).count).to eq(0)

      estimation.reload.estimation_items.each do |i|
        expect(page.get_by_text(i.title)).to be_visible
      end
    end
  end

  context "Estimation sets deletions" do
    it 'should be possible without AJAX' do
      visit estimations_path

      buttons = page.all('button', :text => '×')
      expect(buttons.size).to eq(estimations_count)
      expect(page).to have_text(estimation.title)

      buttons.first.click

      expect(page.status_code).to eq(200)

      new_buttons = page.all('button', :text => '×')
      expect(new_buttons.size).to eq(estimations_count-1)
      expect(page).not_to have_text(estimation.title)
    end

    it 'should be possible with AJAX', :playwright do
      visit estimations_path

      expect(page.locator("button:has-text('×')").count).to eq(estimations_count)
      expect(page.get_by_text(estimation.title)).to be_visible

      # Find the specific button within the estimation div
      button_to_click = page.locator("##{dom_id estimation}").locator("button:has-text('×')")

      # Set up dialog handler before clicking
      page.once('dialog', ->(dialog) { dialog.accept })
      button_to_click.click

      # Wait for the estimation to be removed from the DOM
      page.locator("##{dom_id estimation}").wait_for(state: 'hidden', timeout: 5000)

      expect(page.get_by_text(estimation.title).count).to eq(0)

      user.reload.estimations.each do |e|
        expect(page.get_by_text(e.title)).to be_visible
      end

      # Verify the estimation is still gone after a full page reload
      visit estimations_path
      expect(page.get_by_text(estimation.title).count).to eq(0)

      user.reload.estimations.each do |e|
        expect(page.get_by_text(e.title)).to be_visible
      end
    end
  end

end
