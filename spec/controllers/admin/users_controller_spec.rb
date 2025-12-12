require "rails_helper"

RSpec.describe Admin::UsersController, type: :controller do
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

      it "assigns users ordered by created_at desc" do
        old_user = FactoryBot.create(:user, created_at: 2.days.ago)
        new_user = FactoryBot.create(:user, created_at: 1.hour.ago)

        get :index

        users = assigns(:users).to_a
        # Admin is newest, then new_user, then old_user
        expect(users.map(&:email)).to eq([admin.email, new_user.email, old_user.email])
      end

      it "includes all users" do
        FactoryBot.create_list(:user, 3)
        FactoryBot.create(:user, :banned)

        get :index

        # 3 regular + 1 banned + 1 admin = 5
        expect(assigns(:users).to_a.size).to eq(5)
      end
    end
  end

  describe "POST ban" do
    context "when not authenticated" do
      it "redirects to sign in page" do
        user = FactoryBot.create(:user)

        post :ban, params: { id: user.id }

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated as non-admin" do
      let(:user) { FactoryBot.create(:user) }
      let(:target_user) { FactoryBot.create(:user) }

      before do
        allow(ENV).to receive(:fetch).with('ADMIN_EMAILS', '').and_return('admin@example.com')
        sign_in user
      end

      it "redirects to root path" do
        post :ban, params: { id: target_user.id }

        expect(response).to redirect_to(root_path)
      end
    end

    context "when authenticated as admin" do
      let(:admin) { FactoryBot.create(:user, email: 'admin@example.com') }
      let(:target_user) { FactoryBot.create(:user, email: 'regular@example.com') }

      before do
        allow(ENV).to receive(:fetch).with('ADMIN_EMAILS', '').and_return('admin@example.com')
        sign_in admin
      end

      it "bans the target user" do
        post :ban, params: { id: target_user.id }

        expect(target_user.reload.banned?).to be true
      end

      it "sets banned_by_email to admin email" do
        post :ban, params: { id: target_user.id }

        expect(target_user.reload.banned_by_email).to eq('admin@example.com')
      end

      it "redirects to admin users path" do
        post :ban, params: { id: target_user.id }

        expect(response).to redirect_to(admin_users_path)
      end

      it "sets success flash message" do
        post :ban, params: { id: target_user.id }

        expect(flash[:notice]).to eq("User #{target_user.email} has been banned.")
      end

      context "when trying to ban an admin user" do
        let(:other_admin) { FactoryBot.create(:user, email: 'admin2@example.com') }

        before do
          allow(ENV).to receive(:fetch).with('ADMIN_EMAILS', '').and_return('admin@example.com,admin2@example.com')
        end

        it "does not ban the admin user" do
          post :ban, params: { id: other_admin.id }

          expect(other_admin.reload.banned?).to be false
        end

        it "redirects to admin users path" do
          post :ban, params: { id: other_admin.id }

          expect(response).to redirect_to(admin_users_path)
        end

        it "sets alert flash message" do
          post :ban, params: { id: other_admin.id }

          expect(flash[:alert]).to eq('Cannot ban admin users.')
        end
      end
    end
  end

  describe "POST unban" do
    context "when not authenticated" do
      it "redirects to sign in page" do
        user = FactoryBot.create(:user, :banned)

        post :unban, params: { id: user.id }

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated as non-admin" do
      let(:user) { FactoryBot.create(:user) }
      let(:banned_user) { FactoryBot.create(:user, :banned) }

      before do
        allow(ENV).to receive(:fetch).with('ADMIN_EMAILS', '').and_return('admin@example.com')
        sign_in user
      end

      it "redirects to root path" do
        post :unban, params: { id: banned_user.id }

        expect(response).to redirect_to(root_path)
      end
    end

    context "when authenticated as admin" do
      let(:admin) { FactoryBot.create(:user, email: 'admin@example.com') }
      let(:banned_user) { FactoryBot.create(:user, :banned, email: 'banned@example.com') }

      before do
        allow(ENV).to receive(:fetch).with('ADMIN_EMAILS', '').and_return('admin@example.com')
        sign_in admin
      end

      it "unbans the target user" do
        post :unban, params: { id: banned_user.id }

        expect(banned_user.reload.banned?).to be false
      end

      it "clears banned_at" do
        post :unban, params: { id: banned_user.id }

        expect(banned_user.reload.banned_at).to be_nil
      end

      it "clears banned_by_email" do
        post :unban, params: { id: banned_user.id }

        expect(banned_user.reload.banned_by_email).to be_nil
      end

      it "redirects to admin users path" do
        post :unban, params: { id: banned_user.id }

        expect(response).to redirect_to(admin_users_path)
      end

      it "sets success flash message" do
        post :unban, params: { id: banned_user.id }

        expect(flash[:notice]).to eq("User #{banned_user.email} has been unbanned.")
      end
    end
  end
end
