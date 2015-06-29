require 'rails_helper'

RSpec.describe EstimationsController, :type => :controller do

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

    it 'loads estimations for the current user' do
      user = FactoryGirl.create(:user_with_estimations)
      sign_in user

      get :index

      expect(assigns(:estimations)).to match_array(user.estimations)
    end

    it 'decorates collection of Estimations' do
      user = FactoryGirl.create(:user_with_estimations)
      sign_in user

      get :index

      expect(assigns(:estimations)).to be_decorated
      expect(assigns(:estimations).first).to be_decorated
    end
  end

  describe "GET show" do
    it 'decorates loaded Estimation' do
      user = FactoryGirl.create(:user_with_estimations)
      sign_in user
      estimation = user.estimations.first

      get :show, id: estimation.id

      expect(assigns(:estimation)).to be_decorated
    end
  end

  describe 'PATCH update' do
    let(:user) { FactoryGirl.create(:user_with_estimations) }
    let(:estimation) { user.estimations.first }

    before(:each) do
      sign_in user
    end

    it 'allows changing of Estimation#tracking_mode' do
      xhr :patch, :update, id: estimation.id, estimation: { tracking_mode: true }

      expect(estimation.reload.tracking_mode?).to be_truthy
    end

    it 'redirects to the estimation if no XHR happened' do
      patch :update, id: estimation.id, estimation: { tracking_mode: true }
      expect(response).to redirect_to(estimation_path(estimation))
    end
  end
end
