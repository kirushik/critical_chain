require 'rails_helper'

RSpec.describe EstimationItemsController, :type => :controller do

  describe "POST create" do

    let(:user) { FactoryGirl.create(:user_with_estimations) }
    let(:estimation) { user.estimations.first }

    before(:each) do
      sign_in user
    end


    it "adds an item to the estimation when authorized" do
      expect(estimation.estimation_items.size).to eq(0)

      post :create, estimation_id: estimation.id, estimation_item: { value: 117 }
      expect(response).to redirect_to(estimation_path(estimation))

      expect(estimation.reload.estimation_items.size).to eq(1)
    end

    it "doesn\'t allow to add items to estimations of others" do
      sign_in FactoryGirl.create(:user)

      post :create, estimation_id: estimation.id, estimation_item: { value: 117 }

      expect(response).to have_http_status(403)
      expect(estimation.reload.estimation_items.size).to eq(0)
    end

    it "decorates loaded Estimation" do
      post :create, estimation_id: estimation.id, estimation_item: { value: 117 }
      
      expect(assigns(:estimation)).to be_decorated
    end
  end
end
