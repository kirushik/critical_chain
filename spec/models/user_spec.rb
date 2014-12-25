# == Schema Information
#
# Table name: users
#
#  id                  :integer          not null, primary key
#  email               :string           default(""), not null
#  remember_created_at :datetime
#  sign_in_count       :integer          default("0"), not null
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
  let(:user) { FactoryGirl.create(:google_user) }
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
end
