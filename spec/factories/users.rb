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

FactoryBot.define do
  factory :user do
    sequence(:email) { Faker::Internet.email }

    factory :google_user do
      provider { "google_oauth2" }
      sequence(:uid) { Faker::Number.number(digits: 25) }
    end

    factory :user_with_nonempty_estimations do
      transient do
        n { 1 }
      end

      after(:create) do |user, evaluator|
        FactoryBot.create_list(:estimation_with_items, evaluator.n, :user => user)
      end
    end

    factory :user_with_estimations do
      transient do
        n { 2 }
      end

      after(:create) do |user, evaluator|
        FactoryBot.create_list(:estimation, evaluator.n, :user => user)
      end
    end
  end
end
