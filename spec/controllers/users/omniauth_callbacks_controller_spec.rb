require "rails_helper"

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "GET google_oauth2" do
    let(:auth_hash) do
      OmniAuth::AuthHash.new({
        provider: 'google_oauth2',
        uid: '123456',
        info: {
          email: 'user@example.com'
        }
      })
    end

    before do
      OmniAuth.config.test_mode = true
      request.env['omniauth.auth'] = auth_hash
    end

    context "when user is not banned" do
      let!(:user) { FactoryBot.create(:google_user, uid: '123456', email: 'user@example.com') }

      it "signs in the user" do
        get :google_oauth2

        expect(controller.current_user).to eq(user)
      end

      it "sets success flash message" do
        get :google_oauth2

        expect(flash[:notice]).to eq('Successfully authenticated from Google account.')
      end

      it "redirects to root path" do
        get :google_oauth2

        expect(response).to redirect_to(root_path)
      end
    end

    context "when user is banned" do
      let!(:banned_user) do
        FactoryBot.create(:google_user, :banned, uid: '123456', email: 'user@example.com')
      end

      it "does not sign in the user" do
        get :google_oauth2

        expect(controller.current_user).to be_nil
      end

      it "sets banned alert flash message" do
        get :google_oauth2

        expect(flash[:alert]).to eq('Your account has been suspended. Please contact support.')
      end

      it "redirects to sign in page" do
        get :google_oauth2

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
