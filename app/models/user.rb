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
