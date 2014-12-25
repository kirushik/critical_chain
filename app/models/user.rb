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

class User < ActiveRecord::Base
  devise :omniauthable, :rememberable, :trackable, :omniauth_providers => [:google_oauth2]

  def self.from_omniauth auth, current_user = nil
    return current_user if current_user
    
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      # user.name = auth.info.name   # assuming the user model has a name
      # user.image = auth.info.image # assuming the user model has an image
    end

  end
end
