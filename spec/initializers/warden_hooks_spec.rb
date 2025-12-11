require 'rails_helper'

RSpec.describe 'Warden hooks', type: :feature do
  let(:admin) { FactoryBot.create(:user, email: 'admin@example.com') }

  before do
    allow(ENV).to receive(:fetch).with('ADMIN_EMAILS', '').and_return('admin@example.com')
  end

  describe 'after_set_user hook for banned users' do
    it 'logs out a banned user when their session is loaded' do
      user = FactoryBot.create(:user, email: 'user@example.com')
      
      # Sign in as the user
      login_as user
      visit root_path
      expect(page).to have_link('Sign out')
      
      # Ban the user
      user.ban!(admin)
      
      # Try to access a page with the existing session
      visit root_path
      
      # Should be redirected to sign in page
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_text('Your account has been suspended')
    end

    it 'allows a non-banned user to continue their session' do
      user = FactoryBot.create(:user, email: 'user@example.com')
      
      # Sign in as the user
      login_as user
      visit root_path
      expect(page).to have_link('Sign out')
      
      # Access another page - should work fine
      visit root_path
      expect(page).to have_link('Sign out')
    end
  end
end
