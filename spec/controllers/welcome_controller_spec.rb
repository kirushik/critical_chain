require 'rails_helper'

RSpec.describe WelcomeController, :type => :controller do

  describe 'GET index' do
    it 'redirects to /sign_in'
    it 'returns http success when logged in'
    # get :index
    # expect(response).to have_http_status(:success)
  end

end
