# == Schema Information
#
# Table name: users
#
#  id                  :integer          not null, primary key
#  banned_at           :datetime
#  banned_by_email     :string
#  current_sign_in_at  :datetime
#  current_sign_in_ip  :string
#  email               :string           default(""), not null
#  last_sign_in_at     :datetime
#  last_sign_in_ip     :string
#  provider            :string
#  remember_created_at :datetime
#  sign_in_count       :integer          default(0), not null
#  uid                 :string
#  created_at          :datetime
#  updated_at          :datetime
#
# Indexes
#
#  index_users_on_banned_at  (banned_at)
#  index_users_on_email      (email) UNIQUE
#  index_users_on_provider   (provider)
#  index_users_on_uid        (uid)
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

    trait :admin do
      email { 'admin@example.com' }
    end

    trait :banned do
      banned_at { Time.current }
      banned_by_email { 'admin@example.com' }
    end
  end
end
