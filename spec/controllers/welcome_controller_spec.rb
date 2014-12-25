require 'rails_helper'

RSpec.describe WelcomeController, :type => :controller do

  describe 'GET index' do
    it 'redirects to /sign_in if not authenticated' do
      get :index

      expect(response).to redirect_to(new_user_session_path)
    end

    it 'returns http success when logged in' do
      user = FactoryGirl.create(:user)
      sign_in user

      get :index

      expect(response).to have_http_status(:success)
    end
  end

end
