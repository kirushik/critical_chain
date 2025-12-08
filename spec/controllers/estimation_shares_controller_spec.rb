require 'rails_helper'

RSpec.describe EstimationSharesController, type: :controller do
  let(:owner) { FactoryBot.create(:user) }
  let(:estimation) { FactoryBot.create(:estimation, user: owner) }
  let(:other_user) { FactoryBot.create(:user) }

  describe 'GET #index' do
    context 'when not authenticated' do
      it 'redirects to sign in' do
        get :index, params: { estimation_id: estimation.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when authenticated as owner' do
      before { sign_in owner }

      it 'returns success' do
        get :index, params: { estimation_id: estimation.id }
        expect(response).to have_http_status(:success)
      end

      it 'loads estimation shares' do
        share = FactoryBot.create(:estimation_share, estimation: estimation)
        get :index, params: { estimation_id: estimation.id }
        expect(assigns(:estimation_shares)).to include(share)
      end
    end

    context 'when authenticated as non-owner' do
      before { sign_in other_user }

      it 'returns forbidden' do
        get :index, params: { estimation_id: estimation.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST #create' do
    before { sign_in owner }

    context 'with valid email for existing user' do
      let(:shared_user) { FactoryBot.create(:user) }

      it 'creates an active share' do
        expect {
          post :create, params: {
            estimation_id: estimation.id,
            estimation_share: {
              shared_with_email: shared_user.email,
              role: 'viewer'
            }
          }
        }.to change(EstimationShare, :count).by(1)

        share = EstimationShare.last
        expect(share.shared_with_user).to eq(shared_user)
        expect(share.shared_with_email).to be_nil
        expect(share.active?).to be true
      end
    end

    context 'with email for non-existent user' do
      it 'creates a pending share' do
        expect {
          post :create, params: {
            estimation_id: estimation.id,
            estimation_share: {
              shared_with_email: 'newuser@example.com',
              role: 'viewer'
            }
          }
        }.to change(EstimationShare, :count).by(1)

        share = EstimationShare.last
        expect(share.shared_with_email).to eq('newuser@example.com')
        expect(share.shared_with_user).to be_nil
        expect(share.pending?).to be true
      end
    end

    context 'with owner role' do
      it 'creates a share with owner role' do
        post :create, params: {
          estimation_id: estimation.id,
          estimation_share: {
            shared_with_email: 'editor@example.com',
            role: 'owner'
          }
        }

        share = EstimationShare.last
        expect(share.owner?).to be true
      end
    end

    context 'with duplicate email' do
      before do
        FactoryBot.create(:estimation_share, estimation: estimation, shared_with_email: 'duplicate@example.com')
      end

      it 'does not create a duplicate share' do
        expect {
          post :create, params: {
            estimation_id: estimation.id,
            estimation_share: {
              shared_with_email: 'duplicate@example.com',
              role: 'viewer'
            }
          }
        }.not_to change(EstimationShare, :count)
      end
    end

    context 'when trying to share with owner' do
      it 'does not create a share' do
        expect {
          post :create, params: {
            estimation_id: estimation.id,
            estimation_share: {
              shared_with_email: owner.email,
              role: 'viewer'
            }
          }
        }.not_to change(EstimationShare, :count)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:share) { FactoryBot.create(:estimation_share, estimation: estimation) }

    context 'when authenticated as owner' do
      before { sign_in owner }

      it 'destroys the share' do
        expect {
          delete :destroy, params: { estimation_id: estimation.id, id: share.id }
        }.to change(EstimationShare, :count).by(-1)
      end

      it 'redirects to shares index' do
        delete :destroy, params: { estimation_id: estimation.id, id: share.id }
        expect(response).to redirect_to(estimation_estimation_shares_path(estimation))
      end
    end

    context 'when authenticated as non-owner' do
      before { sign_in other_user }

      it 'returns forbidden' do
        delete :destroy, params: { estimation_id: estimation.id, id: share.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST #transfer_ownership' do
    context 'with active share' do
      let(:new_owner) { FactoryBot.create(:user) }
      let!(:share) { FactoryBot.create(:estimation_share, :active, :owner, estimation: estimation, shared_with_user: new_owner) }

      before { sign_in owner }

      it 'transfers ownership to shared user' do
        post :transfer_ownership, params: { estimation_id: estimation.id, id: share.id }
        
        expect(estimation.reload.user).to eq(new_owner)
      end

      it 'creates viewer share for old owner' do
        expect {
          post :transfer_ownership, params: { estimation_id: estimation.id, id: share.id }
        }.to change { estimation.estimation_shares.where(shared_with_user: owner).count }.by(1)

        old_owner_share = estimation.estimation_shares.find_by(shared_with_user: owner)
        expect(old_owner_share.viewer?).to be true
      end

      it 'removes the original share' do
        post :transfer_ownership, params: { estimation_id: estimation.id, id: share.id }
        
        expect(EstimationShare.exists?(share.id)).to be false
      end
    end

    context 'with pending share' do
      let!(:share) { FactoryBot.create(:estimation_share, :pending, estimation: estimation, shared_with_email: 'pending@example.com') }

      before { sign_in owner }

      it 'does not transfer ownership' do
        original_owner = estimation.user
        post :transfer_ownership, params: { estimation_id: estimation.id, id: share.id }
        
        expect(estimation.reload.user).to eq(original_owner)
      end

      it 'redirects with error message' do
        post :transfer_ownership, params: { estimation_id: estimation.id, id: share.id }
        expect(flash[:alert]).to include('user has not signed up yet')
      end
    end

    context 'when authenticated as non-owner' do
      let!(:share) { FactoryBot.create(:estimation_share, :active, estimation: estimation) }

      before { sign_in other_user }

      it 'returns forbidden' do
        post :transfer_ownership, params: { estimation_id: estimation.id, id: share.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
