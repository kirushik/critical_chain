# == Schema Information
#
# Table name: estimation_items
#
#  id            :integer          not null, primary key
#  value         :integer
#  title         :string
#  estimation_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  fixed         :boolean          default(FALSE), not null
#  quantity      :integer          default(1), not null
#  actual_value  :float
#
# Indexes
#
#  index_estimation_items_on_estimation_id  (estimation_id)
#

require "rails_helper"

RSpec.describe EstimationItemsController, :type => :controller do
  let(:user) { FactoryBot.create(:user_with_estimations) }
  let(:estimation) { user.estimations.first }

  before(:each) do
    sign_in user
  end

  describe "POST create" do
    it "adds an item to the estimation when authorized" do
      expect(estimation.estimation_items.size).to eq(0)

      post :create, params: { estimation_id: estimation.id, estimation_item: { value: 117 } }
      expect(response).to redirect_to(estimation_path(estimation))

      expect(estimation.reload.estimation_items.size).to eq(1)
    end

    it "doesn\'t allow to add items to estimations of others" do
      sign_in FactoryBot.create(:user)

      post :create, params: { estimation_id: estimation.id, estimation_item: { value: 117 } }

      expect(response).to have_http_status(403)
      expect(estimation.reload.estimation_items.size).to eq(0)
    end

    it "decorates loaded Estimation" do
      post :create, params: { estimation_id: estimation.id, estimation_item: { value: 117 } }

      expect(assigns(:estimation)).to be_decorated
    end

    it "assigns order to newly created item" do
      post :create, params: { estimation_id: estimation.id, estimation_item: { value: 117 } }

      created_item = estimation.reload.estimation_items.first
      expect(created_item.order).to be > 0
    end

    it "assigns incrementing order values to multiple new items" do
      post :create, params: { estimation_id: estimation.id, estimation_item: { value: 10 } }
      first_item = estimation.reload.estimation_items.first

      post :create, params: { estimation_id: estimation.id, estimation_item: { value: 20 } }
      second_item = estimation.reload.estimation_items.last

      expect(first_item.order).to be > 0
      expect(second_item.order).to be > first_item.order
    end

    it "assigns order after existing items" do
      existing_item = FactoryBot.create :estimation_item, estimation: estimation, order: 5.0

      post :create, params: { estimation_id: estimation.id, estimation_item: { value: 30 } }
      new_item = estimation.reload.estimation_items.last

      expect(new_item.order).to be > existing_item.order
    end
  end

  describe "PATCH update" do
    let(:estimation_item) { FactoryBot.create :estimation_item, estimation: estimation }

    it "denies to update quantity to negative numbers" do
      patch :update, params: { id: estimation_item.id, estimation_id: estimation.id, estimation_item: { quantity: -1 }, format: :json }, xhr: true

      expect(JSON.parse(response.body)["success"]).to be_falsey
    end

    it "returns expected set of additional values" do
      patch :update, params: { id: estimation_item.id, estimation_id: estimation.id, estimation_item: { a: 1 }, format: :json }, xhr: true
      decorated_estimation = estimation.decorate

      expect(JSON.parse(response.body)["additionalValues"]).to eq(
        {
          "buffer" => decorated_estimation.buffer,
          "sum" => decorated_estimation.sum,
          "total" => decorated_estimation.total,
          "actual_sum" => decorated_estimation.actual_sum,
          "buffer_health" => decorated_estimation.buffer_health,
          "buffer_health_class" => decorated_estimation.buffer_health_class,
          "update_item_total" => {
            "item" => "#estimation_item_1",
            "total" => decorated_estimation.estimation_items.first.total,
          },
        }
      )
    end

    it "updates the order of an estimation item" do
      item1 = FactoryBot.create :estimation_item, estimation: estimation, order: 1.0
      item2 = FactoryBot.create :estimation_item, estimation: estimation, order: 2.0
      item3 = FactoryBot.create :estimation_item, estimation: estimation, order: 3.0

      # Move item3 between item1 and item2
      new_order = 1.5
      patch :update, params: { id: item3.id, estimation_id: estimation.id, estimation_item: { order: new_order }, format: :json }, xhr: true

      expect(response).to have_http_status(:success)
      expect(item3.reload.order).to eq(new_order)
    end

    it "maintains order between 0 and existing items when moving to first position" do
      item1 = FactoryBot.create :estimation_item, estimation: estimation, order: 1.0
      item2 = FactoryBot.create :estimation_item, estimation: estimation, order: 2.0

      # Move item2 to first position (order should be 0.5)
      new_order = 0.5
      patch :update, params: { id: item2.id, estimation_id: estimation.id, estimation_item: { order: new_order }, format: :json }, xhr: true

      expect(response).to have_http_status(:success)
      expect(item2.reload.order).to eq(new_order)
      
      # Verify items are in correct order
      items = estimation.reload.estimation_items.to_a
      expect(items[0]).to eq(item2)
      expect(items[1]).to eq(item1)
    end
  end
end
