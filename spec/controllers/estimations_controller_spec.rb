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

    it "allows changing of Estimation#title via AJAX" do
      new_title = "New Project Title"
      patch :update, params: { id: estimation.id, estimation: { title: new_title } }, xhr: true

      expect(estimation.reload.title).to eq(new_title)
      expect(response.content_type).to match(%r{application/json})
      json_response = JSON.parse(response.body)
      expect(json_response["success"]).to be_truthy
    end

    it "returns error message when title update fails via AJAX" do
      allow_any_instance_of(Estimation).to receive(:update).and_return(false)
      allow_any_instance_of(Estimation).to receive(:errors).and_return(
        double(full_messages: double(first: "Title can't be blank"))
      )

      patch :update, params: { id: estimation.id, estimation: { title: "" } }, xhr: true

      expect(response.content_type).to match(%r{application/json})
      json_response = JSON.parse(response.body)
      expect(json_response["success"]).to be_falsey
      expect(json_response["msg"]).to eq("Title can't be blank")
    end

    it "redirects to the estimation if no XHR happened" do
      patch :update, params: { id: estimation.id, estimation: { tracking_mode: true } }
      expect(response).to redirect_to(estimation_path(estimation))
    end
  end
end
