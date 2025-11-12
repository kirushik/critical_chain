# == Schema Information
#
# Table name: estimations
#
#  id            :integer          not null, primary key
#  title         :string
#  user_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  tracking_mode :boolean          default(FALSE), not null
#
# Indexes
#
#  index_estimations_on_user_id  (user_id)
#

require "rails_helper"

RSpec.describe EstimationsController, :type => :controller do
  describe "GET index" do
    it "redirects to /sign_in if not authenticated" do
      get :index

      expect(response).to redirect_to(new_user_session_path)
    end

    it "returns http success when logged in" do
      user = FactoryBot.create(:user)
      sign_in user

      get :index

      expect(response).to have_http_status(:success)
    end

    it "loads estimations for the current user" do
      user = FactoryBot.create(:user_with_estimations)
      sign_in user

      get :index

      expect(assigns(:estimations)).to match_array(user.estimations)
    end

    it "decorates collection of Estimations" do
      user = FactoryBot.create(:user_with_estimations)
      sign_in user

      get :index

      expect(assigns(:estimations)).to be_decorated
      expect(assigns(:estimations).first).to be_decorated
    end
  end

  describe "GET show" do
    let(:user) { FactoryBot.create(:user_with_estimations) }
    let(:estimation) { user.estimations.first }

    before(:each) do
      sign_in user
    end

    it "decorates loaded Estimation" do
      get :show, params: { id: estimation.id }

      expect(assigns(:estimation)).to be_decorated
    end

    context "estimation in planning mode" do
      render_views
      let(:estimation) { FactoryBot.create(:estimation, user: user, tracking_mode: false) }

      it "should render planning-related partials" do
        get :show, params: { id: estimation.id }

        expect(response).to render_template(partial: "estimation_items/_estimation_item_editable", count: estimation.estimation_items.count)
        expect(response).to render_template(partial: "estimation_items/_form_for_new")
        expect(response).to render_template(partial: "estimations/_results")
        expect(response).to render_template(partial: "estimations/_mode_toggle")
      end
    end

    context "estimation in tracking mode" do
      render_views
      let(:estimation) { FactoryBot.create(:estimation, user: user, tracking_mode: true) }

      it "should render tracking-related partials" do
        get :show, params: { id: estimation.id }

        expect(response).to render_template(partial: "estimation_items/_estimation_item_trackable", count: estimation.estimation_items.count)
        expect(response).to render_template(partial: "estimations/_graph")
        expect(response).to render_template(partial: "estimations/_results")
        expect(response).to render_template(partial: "estimations/_mode_toggle")
      end
    end

    it "displays estimation items in order specified by order field" do
      # Create items with specific order values (not in creation order)
      item1 = FactoryBot.create(:estimation_item, estimation: estimation, title: 'Third by order', value: 10, order: 3.0)
      item2 = FactoryBot.create(:estimation_item, estimation: estimation, title: 'First by order', value: 20, order: 1.0)
      item3 = FactoryBot.create(:estimation_item, estimation: estimation, title: 'Second by order', value: 30, order: 2.0)

      get :show, params: { id: estimation.id }

      # Verify items are ordered by the order field in the decorated collection
      items = assigns(:estimation).estimation_items.to_a
      expect(items[0].title).to eq('First by order')
      expect(items[1].title).to eq('Second by order')
      expect(items[2].title).to eq('Third by order')
    end
  end

  describe "PATCH update" do
    let(:user) { FactoryBot.create(:user_with_estimations) }
    let(:estimation) { user.estimations.first }

    before(:each) do
      sign_in user
    end

    it "allows changing of Estimation#tracking_mode" do
      patch :update, params: { id: estimation.id, estimation: { tracking_mode: true } }, xhr: true

      expect(estimation.reload.tracking_mode?).to be_truthy
    end

    it "allows changing of Estimation#title via Turbo Stream" do
      new_title = "New Project Title"
      patch :update, params: { id: estimation.id, estimation: { title: new_title } }, format: :turbo_stream

      expect(estimation.reload.title).to eq(new_title)
      expect(response.content_type).to match(%r{text/vnd.turbo-stream})
      expect(response.body).to include('turbo-stream')
      expect(response.body).to include(new_title)
    end

    it "returns error message when title update fails via Turbo Stream" do
      # Stub validation to fail for testing error handling
      allow_any_instance_of(Estimation).to receive(:update).and_return(false)
      allow_any_instance_of(Estimation).to receive(:errors).and_return(
        double(full_messages: double(first: "Title is invalid"))
      )

      patch :update, params: { id: estimation.id, estimation: { title: "Bad Title" } }, format: :turbo_stream

      expect(response.content_type).to match(%r{text/vnd.turbo-stream})
      expect(response.status).to eq(422)
      expect(response.body).to include('turbo-stream')
      expect(response.body).to include('alert')
    end

    it "redirects to the estimation if no XHR happened" do
      patch :update, params: { id: estimation.id, estimation: { tracking_mode: true } }
      expect(response).to redirect_to(estimation_path(estimation))
    end
  end
end
