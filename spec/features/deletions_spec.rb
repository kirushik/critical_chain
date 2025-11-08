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

    it 'should be possible with AJAX', :js do
      visit estimation_path(estimation)

      buttons = page.all('button', :text => '×')
      expect(buttons.size).to eq(items_count)
      expect(page).to have_text(first_item.title)

      buttons.first.click

      wait_for_ajax

      new_buttons = page.all('button', :text => '×')
      expect(new_buttons.size).to eq(items_count-1)
      expect(page).not_to have_text(first_item.title)

      estimation.reload.estimation_items.each do |i|
        expect(page).to have_text(i.title)
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

    it 'should be possible with AJAX', :js do
      visit estimations_path

      buttons = page.all('button', :text => '×')
      expect(buttons.size).to eq(estimations_count)
      expect(page).to have_text(estimation.title)

      within("\##{dom_id estimation}") do
        accept_confirm do
          click_button '×'
        end
      end

      wait_for_ajax

      expect(page).not_to have_text(estimation.title)

      user.reload.estimations.each do |e|
        expect(page).to have_text(e.title)
      end

      # Verify the estimation is still gone after a full page reload
      visit estimations_path
      expect(page).not_to have_text(estimation.title)

      user.reload.estimations.each do |e|
        expect(page).to have_text(e.title)
      end
    end
  end

end
