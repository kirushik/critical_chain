class User < ActiveRecord::Base
  devise :omniauthable, :rememberable, :trackable, :omniauth_providers => [:google_oauth2]
end
