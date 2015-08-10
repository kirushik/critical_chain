require 'rails_helper'

RSpec.describe EstimationItemsController, :type => :controller do

  let(:user) { FactoryGirl.create(:user_with_estimations) }
  let(:estimation) { user.estimations.first }

  before(:each) do
    sign_in user
  end

  describe "POST create" do
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

  describe "PATCH update" do
    let(:estimation_item) { FactoryGirl.create :estimation_item, estimation: estimation }

    it 'denies to update quantity to negative numbers' do
      xhr :patch, :update, id: estimation_item.id, estimation_id: estimation.id, estimation_item: { quantity: -1 }, format: :json

      expect(JSON.parse(response.body)['success']).to be_falsey
    end

    it 'returns expected set of additional values' do
      xhr :patch, :update, id: estimation_item.id, estimation_id: estimation.id, estimation_item: { a: 1 }, format: :json
      decorated_estimation = estimation.decorate

      expect(JSON.parse(response.body)['additionalValues']).to eq(
        {
          'buffer' => decorated_estimation.buffer,
          'sum' => decorated_estimation.sum,
          'total' => decorated_estimation.total,
          'actual_sum' => decorated_estimation.actual_sum,
          'buffer_health' => decorated_estimation.buffer_health,
          'buffer_health_class' => decorated_estimation.buffer_health_class
        }
      )
    end
  end
end
