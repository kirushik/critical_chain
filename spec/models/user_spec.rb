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
#
# Indexes
#
#  index_users_on_email     (email) UNIQUE
#  index_users_on_provider  (provider)
#  index_users_on_uid       (uid)
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
end
