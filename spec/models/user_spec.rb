# == Schema Information
#
# Table name: users
#
#  id                  :integer          not null, primary key
#  email               :string           default(""), not null
#  remember_created_at :datetime
#  sign_in_count       :integer          default(0), not null
#  current_sign_in_at  :datetime
#  last_sign_in_at     :datetime
#  current_sign_in_ip  :string
#  last_sign_in_ip     :string
#  created_at          :datetime
#  updated_at          :datetime
#  provider            :string
#  uid                 :string
#  banned_at           :datetime
#  banned_by_email     :string
#
# Indexes
#
#  index_users_on_banned_at  (banned_at)
#  index_users_on_email      (email) UNIQUE
#  index_users_on_provider   (provider)
#  index_users_on_uid        (uid)
#

require 'rails_helper'

def oauth_payload_for uid, email = Faker::Internet.email
end

RSpec.describe User, :type => :model do
  let(:user) { FactoryBot.create(:google_user) }
  def oauth_payload email = nil
    payload = double
    allow(payload).to receive_messages(provider: 'google_oauth2', uid: user.uid)

    if email
      info = double
      allow(info).to receive(:email).and_return email
      allow(payload).to receive(:info).and_return(info)
    end

    payload
  end

  describe 'from_omniauth method' do
    it 'should return existing object when second parameter is present' do
      new_user = User.from_omniauth(nil, user)

      expect(new_user.object_id).to eq(user.object_id)
    end

    it 'should create user if it is not in the database' do
      user.delete
      expect(User.count).to eq(0)

      new_user = User.from_omniauth oauth_payload('aaa@example.com')

      expect(new_user.uid).to eq(user.uid)
      expect(new_user.email).to eq('aaa@example.com')
      expect(User.count).to eq(1)
    end

    it 'should locate user if it is in the database' do
      new_user = User.from_omniauth oauth_payload

      expect(new_user).to eq(user)
    end
  end

  describe "estimations" do
    it "should be an array" do
      expect(user.estimations).to match_array([])
    end

    it "should not include other user's estimations" do
      user = FactoryBot.create(:user_with_estimations, n: 3)
      FactoryBot.create(:user_with_estimations)

      user = User.find(user.id)

      expect(user.estimations.size).to eq(3)
    end
  end

  describe "#activate_pending_shares" do
    let(:user) { FactoryBot.create(:user, email: 'test@example.com') }

    it 'activates pending shares for the user email' do
      estimation1 = FactoryBot.create(:estimation)
      estimation2 = FactoryBot.create(:estimation)
      
      share1 = FactoryBot.create(:estimation_share, :pending, estimation: estimation1, shared_with_email: 'test@example.com')
      share2 = FactoryBot.create(:estimation_share, :pending, estimation: estimation2, shared_with_email: 'test@example.com')
      other_share = FactoryBot.create(:estimation_share, :pending, shared_with_email: 'other@example.com')
      
      user.activate_pending_shares
      
      expect(share1.reload.shared_with_user).to eq(user)
      expect(share2.reload.shared_with_user).to eq(user)
      expect(other_share.reload.shared_with_user).to be_nil
    end

    it 'is called after user creation' do
      estimation = FactoryBot.create(:estimation)
      FactoryBot.create(:estimation_share, :pending, estimation: estimation, shared_with_email: 'newuser@example.com')
      
      new_user = FactoryBot.create(:user, email: 'newuser@example.com')
      
      share = estimation.estimation_shares.first
      expect(share.reload.shared_with_user).to eq(new_user)
    end
  end

  describe '.from_omniauth' do
    it 'activates pending shares when user signs in' do
      estimation = FactoryBot.create(:estimation)
      FactoryBot.create(:estimation_share, :pending, estimation: estimation, shared_with_email: 'oauth@example.com')

      payload = double
      info = double
      allow(payload).to receive_messages(provider: 'google_oauth2', uid: '12345')
      allow(info).to receive(:email).and_return('oauth@example.com')
      allow(payload).to receive(:info).and_return(info)

      user = User.from_omniauth(payload)

      share = estimation.estimation_shares.first
      expect(share.reload.shared_with_user).to eq(user)
    end
  end

  describe '#admin?' do
    it 'returns false when ADMIN_EMAILS is not set' do
      allow(ENV).to receive(:fetch).with('ADMIN_EMAILS', '').and_return('')
      user = FactoryBot.create(:user, email: 'user@example.com')

      expect(user.admin?).to be false
    end

    it 'returns true when user email is in ADMIN_EMAILS' do
      allow(ENV).to receive(:fetch).with('ADMIN_EMAILS', '').and_return('admin@example.com,admin2@example.com')
      user = FactoryBot.create(:user, email: 'admin@example.com')

      expect(user.admin?).to be true
    end

    it 'returns false when user email is not in ADMIN_EMAILS' do
      allow(ENV).to receive(:fetch).with('ADMIN_EMAILS', '').and_return('admin@example.com')
      user = FactoryBot.create(:user, email: 'regular@example.com')

      expect(user.admin?).to be false
    end

    it 'is case insensitive' do
      allow(ENV).to receive(:fetch).with('ADMIN_EMAILS', '').and_return('Admin@Example.COM')
      user = FactoryBot.create(:user, email: 'admin@example.com')

      expect(user.admin?).to be true
    end

    it 'handles whitespace in ADMIN_EMAILS' do
      allow(ENV).to receive(:fetch).with('ADMIN_EMAILS', '').and_return('admin@example.com , admin2@example.com')
      user = FactoryBot.create(:user, email: 'admin2@example.com')

      expect(user.admin?).to be true
    end

    it 'returns false when email is blank' do
      allow(ENV).to receive(:fetch).with('ADMIN_EMAILS', '').and_return('admin@example.com')
      user = FactoryBot.build(:user, email: '')

      expect(user.admin?).to be false
    end
  end

  describe '#banned?' do
    it 'returns true when banned_at is present' do
      user = FactoryBot.create(:user, :banned)

      expect(user.banned?).to be true
    end

    it 'returns false when banned_at is nil' do
      user = FactoryBot.create(:user)

      expect(user.banned?).to be false
    end
  end

  describe '#ban!' do
    let(:admin) { FactoryBot.create(:user, email: 'admin@example.com') }
    let(:user_to_ban) { FactoryBot.create(:user) }

    it 'sets banned_at to current time' do
      user_to_ban.ban!(admin)

      expect(user_to_ban.banned_at).to be_within(1.second).of(Time.current)
    end

    it 'sets banned_by_email to admin email' do
      user_to_ban.ban!(admin)

      expect(user_to_ban.banned_by_email).to eq('admin@example.com')
    end

    it 'persists the changes' do
      user_to_ban.ban!(admin)

      expect(user_to_ban.reload.banned?).to be true
    end
  end

  describe '#unban!' do
    let(:banned_user) { FactoryBot.create(:user, :banned) }

    it 'clears banned_at' do
      banned_user.unban!

      expect(banned_user.banned_at).to be_nil
    end

    it 'clears banned_by_email' do
      banned_user.unban!

      expect(banned_user.banned_by_email).to be_nil
    end

    it 'persists the changes' do
      banned_user.unban!

      expect(banned_user.reload.banned?).to be false
    end
  end

  describe '#active_for_authentication?' do
    it 'returns true for non-banned users' do
      user = FactoryBot.create(:user)

      expect(user.active_for_authentication?).to be true
    end

    it 'returns false for banned users' do
      user = FactoryBot.create(:user, :banned)

      expect(user.active_for_authentication?).to be false
    end
  end

  describe '#inactive_message' do
    it 'returns :banned for banned users' do
      user = FactoryBot.create(:user, :banned)

      expect(user.inactive_message).to eq(:banned)
    end

    it 'returns default message for non-banned users' do
      user = FactoryBot.create(:user)

      expect(user.inactive_message).to eq(:inactive)
    end
  end
end
