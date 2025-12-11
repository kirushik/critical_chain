# == Schema Information
#
# Table name: estimation_shares
#
#  id                  :integer          not null, primary key
#  estimation_id       :integer          not null
#  shared_with_user_id :integer
#  shared_with_email   :string
#  last_accessed_at    :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_estimation_shares_on_estimation_and_email  (estimation_id,shared_with_email) UNIQUE
#  index_estimation_shares_on_estimation_and_user   (estimation_id,shared_with_user_id) UNIQUE
#  index_estimation_shares_on_estimation_id         (estimation_id)
#  index_estimation_shares_on_shared_with_email     (shared_with_email)
#  index_estimation_shares_on_shared_with_user_id   (shared_with_user_id)
#
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
              shared_with_email: shared_user.email
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
              shared_with_email: 'newuser@example.com'
            }
          }
        }.to change(EstimationShare, :count).by(1)

        share = EstimationShare.last
        expect(share.shared_with_email).to eq('newuser@example.com')
        expect(share.shared_with_user).to be_nil
        expect(share.pending?).to be true
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
              shared_with_email: 'duplicate@example.com'
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
              shared_with_email: owner.email
            }
          }
        }.not_to change(EstimationShare, :count)
      end
    end

    context 'with case-insensitive email handling' do
      it 'finds existing user regardless of email case in input' do
        # Devise normalizes emails to lowercase, so user will have lowercase email
        shared_user = FactoryBot.create(:user, email: 'test.user@example.com')

        expect {
          post :create, params: {
            estimation_id: estimation.id,
            estimation_share: {
              shared_with_email: 'TEST.USER@EXAMPLE.COM'
            }
          }
        }.to change(EstimationShare, :count).by(1)

        share = EstimationShare.last
        expect(share.shared_with_user).to eq(shared_user)
        expect(share.active?).to be true
      end

      it 'normalizes email to lowercase for pending shares' do
        expect {
          post :create, params: {
            estimation_id: estimation.id,
            estimation_share: {
              shared_with_email: 'NEW.USER@EXAMPLE.COM'
            }
          }
        }.to change(EstimationShare, :count).by(1)

        share = EstimationShare.last
        expect(share.shared_with_email).to eq('new.user@example.com')
      end

      it 'detects duplicate share regardless of email case' do
        FactoryBot.create(:estimation_share, estimation: estimation, shared_with_email: 'duplicate@example.com')

        expect {
          post :create, params: {
            estimation_id: estimation.id,
            estimation_share: {
              shared_with_email: 'DUPLICATE@EXAMPLE.COM'
            }
          }
        }.not_to change(EstimationShare, :count)

        expect(flash[:notice]).to include('already has access')
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
      let!(:share) { FactoryBot.create(:estimation_share, :active, estimation: estimation, shared_with_user: new_owner) }

      before { sign_in owner }

      it 'transfers ownership to shared user' do
        post :transfer_ownership, params: { estimation_id: estimation.id, id: share.id }

        expect(estimation.reload.user).to eq(new_owner)
      end

      it 'creates share for old owner' do
        expect {
          post :transfer_ownership, params: { estimation_id: estimation.id, id: share.id }
        }.to change { estimation.estimation_shares.where(shared_with_user: owner).count }.by(1)
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
