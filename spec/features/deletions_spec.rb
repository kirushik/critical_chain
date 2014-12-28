require 'rails_helper'

feature "Deletions", :type => :feature do
  let(:user) { FactoryGirl.create(:user_with_nonempty_estimation) }
  let(:estimation) { user.estimations.first }
  let(:first_item) { estimation.estimation_items.first }
  let(:items_count) { estimation.estimation_items.size }

  before(:each) do
    login_as user
  end

  context "Items deletion" do
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

    it 'should be possible with AJAX', :js
  end

  context "Estimation sets deletion" do
    it 'should be possible without AJAX'
    it 'should be possible with AJAX'
  end

end
