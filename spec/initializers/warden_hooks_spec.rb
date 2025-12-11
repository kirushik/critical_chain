require 'rails_helper'

RSpec.describe 'Warden hooks', type: :request do
  let(:admin) { FactoryBot.create(:user, email: 'admin@example.com') }

  before do
    allow(ENV).to receive(:fetch).with('ADMIN_EMAILS', '').and_return('admin@example.com')
  end

  describe 'after_set_user hook for banned users' do
    it 'logs out a banned user when their session is loaded' do
      user = FactoryBot.create(:user, email: 'user@example.com')
      
      # Sign in as the user
      sign_in user
      get root_path
      expect(response).to have_http_status(:success)
      
      # Ban the user
      user.ban!(admin)
      
      # Try to access a page with the existing session
      get root_path
      
      # Should be redirected to sign in page
      expect(response).to redirect_to(new_user_session_path)
      
      # Follow redirect to see the flash message
      follow_redirect!
      expect(response.body).to include('Your account has been suspended')
    end

    it 'allows a non-banned user to continue their session' do
      user = FactoryBot.create(:user, email: 'user@example.com')
      
      # Sign in as the user
      sign_in user
      get root_path
      expect(response).to have_http_status(:success)
      
      # Access another page - should work fine
      get root_path
      expect(response).to have_http_status(:success)
    end
  end
end
