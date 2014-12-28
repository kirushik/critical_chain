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

FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }

    factory :google_user do
      provider 'google_oauth2'
      uid { Faker::Number.number(25) }
    end

    factory :user_with_nonempty_estimation do
    end
    
    factory :user_with_estimations do
      transient do
        estimations 2
      end

      after(:create) do |user, evaluator|
        FactoryGirl.create_list(:estimation, evaluator.estimations, :user => user)
      end
    end
  end
end
