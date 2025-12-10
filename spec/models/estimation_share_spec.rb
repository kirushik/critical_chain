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

RSpec.describe EstimationShare, type: :model do
  describe 'associations' do
    it 'belongs to estimation' do
      share = FactoryBot.build(:estimation_share)
      expect(share).to respond_to(:estimation)
    end

    it 'belongs to shared_with_user optionally' do
      share = FactoryBot.build(:estimation_share, :pending)
      expect(share.shared_with_user).to be_nil
      expect(share).to be_valid
    end
  end

  describe 'validations' do
    subject { FactoryBot.build(:estimation_share) }

    it 'requires either user or email' do
      share = FactoryBot.build(:estimation_share, shared_with_user: nil, shared_with_email: nil)
      expect(share).not_to be_valid
      expect(share.errors[:base]).to include('Must specify either a user or an email address')
    end

    it 'validates email format when email is present' do
      share = FactoryBot.build(:estimation_share, shared_with_email: 'invalid_email')
      expect(share).not_to be_valid
      expect(share.errors[:shared_with_email]).to be_present
    end

    it 'validates uniqueness of user per estimation' do
      user = FactoryBot.create(:user)
      estimation = FactoryBot.create(:estimation)
      FactoryBot.create(:estimation_share, :active, estimation: estimation, shared_with_user: user)

      duplicate = FactoryBot.build(:estimation_share, :active, estimation: estimation, shared_with_user: user)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:shared_with_user]).to include('already has access to this estimation')
    end

    it 'validates uniqueness of email per estimation' do
      estimation = FactoryBot.create(:estimation)
      FactoryBot.create(:estimation_share, :pending, estimation: estimation, shared_with_email: 'test@example.com')

      duplicate = FactoryBot.build(:estimation_share, :pending, estimation: estimation, shared_with_email: 'test@example.com')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:shared_with_email]).to include('already has access to this estimation')
    end

    it 'allows same email for different estimations' do
      share1 = FactoryBot.create(:estimation_share, :pending, shared_with_email: 'test@example.com')
      share2 = FactoryBot.build(:estimation_share, :pending, shared_with_email: 'test@example.com')

      expect(share2).to be_valid
    end

    it 'treats emails case-insensitively for uniqueness' do
      estimation = FactoryBot.create(:estimation)
      FactoryBot.create(:estimation_share, :pending, estimation: estimation, shared_with_email: 'test@example.com')

      duplicate = FactoryBot.build(:estimation_share, :pending, estimation: estimation, shared_with_email: 'TEST@EXAMPLE.COM')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:shared_with_email]).to include('already has access to this estimation')
    end

    it 'cannot share with the estimation owner by user_id' do
      user = FactoryBot.create(:user)
      estimation = FactoryBot.create(:estimation, user: user)
      share = FactoryBot.build(:estimation_share, :active, estimation: estimation, shared_with_user: user)

      expect(share).not_to be_valid
      expect(share.errors[:shared_with_user]).to include('cannot share with the estimation owner')
    end

    it 'cannot share with the estimation owner by email' do
      user = FactoryBot.create(:user)
      estimation = FactoryBot.create(:estimation, user: user)
      share = FactoryBot.build(:estimation_share, :pending, estimation: estimation, shared_with_email: user.email)

      expect(share).not_to be_valid
      expect(share.errors[:shared_with_email]).to include('cannot share with the estimation owner')
    end

    it 'cannot share with the estimation owner by email case-insensitively' do
      user = FactoryBot.create(:user, email: 'Owner@Example.com')
      estimation = FactoryBot.create(:estimation, user: user)
      share = FactoryBot.build(:estimation_share, :pending, estimation: estimation, shared_with_email: 'owner@example.com')

      expect(share).not_to be_valid
      expect(share.errors[:shared_with_email]).to include('cannot share with the estimation owner')
    end

    it 'prevents duplicate when email matches existing user share' do
      user = FactoryBot.create(:user, email: 'test@example.com')
      estimation = FactoryBot.create(:estimation)
      FactoryBot.create(:estimation_share, :active, estimation: estimation, shared_with_user: user)

      duplicate = FactoryBot.build(:estimation_share, :pending, estimation: estimation, shared_with_email: 'test@example.com')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:shared_with_email]).to include('already has access to this estimation')
    end

    it 'prevents duplicate when email matches existing user share case-insensitively' do
      user = FactoryBot.create(:user, email: 'Test@Example.com')
      estimation = FactoryBot.create(:estimation)
      FactoryBot.create(:estimation_share, :active, estimation: estimation, shared_with_user: user)

      duplicate = FactoryBot.build(:estimation_share, :pending, estimation: estimation, shared_with_email: 'test@example.com')
      expect(duplicate).not_to be_valid
    end
  end

  describe 'email normalization' do
    it 'normalizes email to lowercase on save' do
      share = FactoryBot.create(:estimation_share, :pending, shared_with_email: 'TEST@EXAMPLE.COM')
      expect(share.shared_with_email).to eq('test@example.com')
    end

    it 'strips whitespace from email' do
      share = FactoryBot.create(:estimation_share, :pending, shared_with_email: '  test@example.com  ')
      expect(share.shared_with_email).to eq('test@example.com')
    end

    it 'converts empty string email to nil' do
      share = FactoryBot.build(:estimation_share, :active)
      share.shared_with_email = '   '
      share.valid?
      expect(share.shared_with_email).to be_nil
    end

    it 'handles mixed case and whitespace' do
      share = FactoryBot.create(:estimation_share, :pending, shared_with_email: '  Test.User@EXAMPLE.COM  ')
      expect(share.shared_with_email).to eq('test.user@example.com')
    end
  end

  describe 'scopes' do
    let(:user) { FactoryBot.create(:user, email: 'user@example.com') }
    let(:estimation) { FactoryBot.create(:estimation) }
    let!(:active_share) { FactoryBot.create(:estimation_share, :active, estimation: estimation, shared_with_user: user) }
    let!(:pending_share) { FactoryBot.create(:estimation_share, :pending, estimation: estimation, shared_with_email: 'pending@example.com') }

    describe '.for_user' do
      it 'returns active shares for a user' do
        expect(EstimationShare.for_user(user)).to contain_exactly(active_share)
      end

      it 'returns pending shares matching user email' do
        pending_user = FactoryBot.create(:user, email: 'pending@example.com')
        expect(EstimationShare.for_user(pending_user)).to contain_exactly(pending_share)
      end

      it 'matches email case-insensitively' do
        pending_user = FactoryBot.create(:user, email: 'PENDING@EXAMPLE.COM')
        expect(EstimationShare.for_user(pending_user)).to contain_exactly(pending_share)
      end
    end

    describe '.pending' do
      it 'returns only pending shares' do
        expect(estimation.estimation_shares.pending).to contain_exactly(pending_share)
      end
    end

    describe '.active' do
      it 'returns only active shares' do
        expect(estimation.estimation_shares.active).to contain_exactly(active_share)
      end
    end
  end

  describe '#pending?' do
    it 'returns true when shared_with_user_id is nil and email is present' do
      share = FactoryBot.build(:estimation_share, :pending)
      expect(share.pending?).to be true
    end

    it 'returns false when shared_with_user_id is present' do
      share = FactoryBot.build(:estimation_share, :active)
      expect(share.pending?).to be false
    end
  end

  describe '#active?' do
    it 'returns true when shared_with_user_id is present' do
      share = FactoryBot.create(:estimation_share, :active)
      expect(share.active?).to be true
    end

    it 'returns false when shared_with_user_id is nil' do
      share = FactoryBot.build(:estimation_share, :pending)
      expect(share.active?).to be false
    end
  end

  describe '#display_email' do
    it 'returns user email when active' do
      user = FactoryBot.create(:user, email: 'active@example.com')
      share = FactoryBot.build(:estimation_share, :active, shared_with_user: user)
      expect(share.display_email).to eq('active@example.com')
    end

    it 'returns shared_with_email when pending' do
      share = FactoryBot.build(:estimation_share, :pending, shared_with_email: 'pending@example.com')
      expect(share.display_email).to eq('pending@example.com')
    end
  end

  describe '#touch_last_accessed' do
    it 'updates last_accessed_at timestamp' do
      share = FactoryBot.create(:estimation_share, last_accessed_at: nil)

      expect {
        share.touch_last_accessed
      }.to change { share.reload.last_accessed_at }.from(nil)
    end

    it 'does not update updated_at' do
      share = FactoryBot.create(:estimation_share)
      original_updated_at = share.updated_at

      share.touch_last_accessed

      expect(share.reload.updated_at).to eq(original_updated_at)
    end
  end

  describe '#activate_for_user!' do
    it 'converts pending share to active' do
      user = FactoryBot.create(:user, email: 'test@example.com')
      share = FactoryBot.create(:estimation_share, :pending, shared_with_email: 'test@example.com')

      expect(share.activate_for_user!(user)).to be true
      expect(share.reload).to be_active
      expect(share.shared_with_user).to eq(user)
      expect(share.shared_with_email).to be_nil
    end

    it 'activates share with case-insensitive email match' do
      user = FactoryBot.create(:user, email: 'Test@Example.com')
      share = FactoryBot.create(:estimation_share, :pending, shared_with_email: 'test@example.com')

      expect(share.activate_for_user!(user)).to be true
      expect(share.reload).to be_active
    end

    it 'returns false if share is already active' do
      share = FactoryBot.create(:estimation_share, :active)
      user = FactoryBot.create(:user)

      expect(share.activate_for_user!(user)).to be false
    end

    it 'returns false if email does not match' do
      user = FactoryBot.create(:user, email: 'different@example.com')
      share = FactoryBot.create(:estimation_share, :pending, shared_with_email: 'test@example.com')

      expect(share.activate_for_user!(user)).to be false
    end
  end

  describe '.activate_pending_shares_for_user' do
    it 'activates all pending shares for a user' do
      user = FactoryBot.create(:user, email: 'test@example.com')
      estimation1 = FactoryBot.create(:estimation)
      estimation2 = FactoryBot.create(:estimation)

      share1 = FactoryBot.create(:estimation_share, :pending, estimation: estimation1, shared_with_email: 'test@example.com')
      share2 = FactoryBot.create(:estimation_share, :pending, estimation: estimation2, shared_with_email: 'test@example.com')
      other_share = FactoryBot.create(:estimation_share, :pending, shared_with_email: 'other@example.com')

      EstimationShare.activate_pending_shares_for_user(user)

      expect(share1.reload).to be_active
      expect(share2.reload).to be_active
      expect(other_share.reload).to be_pending
    end

    it 'handles user with nil email gracefully' do
      user = FactoryBot.build(:user, email: nil)
      allow(user).to receive(:email).and_return(nil)

      expect { EstimationShare.activate_pending_shares_for_user(user) }.not_to raise_error
    end
  end
end
