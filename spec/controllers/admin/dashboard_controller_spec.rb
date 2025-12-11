require "rails_helper"

RSpec.describe Admin::DashboardController, type: :controller do
  describe "GET index" do
    context "when not authenticated" do
      it "redirects to sign in page" do
        get :index

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated as non-admin" do
      let(:user) { FactoryBot.create(:user) }

      before do
        allow(ENV).to receive(:fetch).with('ADMIN_EMAILS', '').and_return('admin@example.com')
        sign_in user
      end

      it "redirects to root path" do
        get :index

        expect(response).to redirect_to(root_path)
      end

      it "sets alert flash message" do
        get :index

        expect(flash[:alert]).to eq('Access denied. Admin privileges required.')
      end
    end

    context "when authenticated as admin" do
      let(:admin) { FactoryBot.create(:user, email: 'admin@example.com') }

      before do
        allow(ENV).to receive(:fetch).with('ADMIN_EMAILS', '').and_return('admin@example.com')
        sign_in admin
      end

      it "returns http success" do
        get :index

        expect(response).to have_http_status(:success)
      end

      it "renders the index template" do
        get :index

        expect(response).to render_template(:index)
      end

      it "uses the admin layout" do
        get :index

        expect(response).to render_template(layout: 'admin')
      end

      it "assigns stats hash" do
        get :index

        expect(assigns(:stats)).to be_a(Hash)
      end

      describe "stats calculations" do
        before do
          # Create some test data
          FactoryBot.create_list(:user, 3)
          FactoryBot.create(:user, :banned)
          user_with_estimations = FactoryBot.create(:user_with_nonempty_estimations, n: 2)
          FactoryBot.create(:estimation_share, estimation: user_with_estimations.estimations.first)
        end

        it "counts total users including admin" do
          get :index

          # 3 regular users + 1 banned user + 1 with estimations + 1 admin = 6
          expect(assigns(:stats)[:total_users]).to eq(6)
        end

        it "counts banned users" do
          get :index

          expect(assigns(:stats)[:banned_users]).to eq(1)
        end

        it "counts total estimations" do
          get :index

          expect(assigns(:stats)[:total_estimations]).to eq(2)
        end

        it "counts total estimation items" do
          get :index

          expect(assigns(:stats)[:total_estimation_items]).to be >= 0
        end

        it "counts total shares" do
          get :index

          expect(assigns(:stats)[:total_shares]).to eq(1)
        end
      end

      describe "time-based stats" do
        it "counts users created in last 7 days" do
          FactoryBot.create(:user, created_at: 3.days.ago)
          FactoryBot.create(:user, created_at: 10.days.ago)

          get :index

          # Admin + user from 3 days ago
          expect(assigns(:stats)[:users_last_7_days]).to eq(2)
        end

        it "counts users created in last 30 days" do
          FactoryBot.create(:user, created_at: 15.days.ago)
          FactoryBot.create(:user, created_at: 45.days.ago)

          get :index

          # Admin + user from 15 days ago
          expect(assigns(:stats)[:users_last_30_days]).to eq(2)
        end

        it "counts active users in last 7 days" do
          FactoryBot.create(:user, last_sign_in_at: 3.days.ago)
          FactoryBot.create(:user, last_sign_in_at: 10.days.ago)

          get :index

          expect(assigns(:stats)[:active_users_last_7_days]).to eq(1)
        end

        it "counts estimations created in last 7 days" do
          user = FactoryBot.create(:user)
          FactoryBot.create(:estimation, user: user, created_at: 3.days.ago)
          FactoryBot.create(:estimation, user: user, created_at: 10.days.ago)

          get :index

          expect(assigns(:stats)[:estimations_last_7_days]).to eq(1)
        end
      end
    end
  end
end
