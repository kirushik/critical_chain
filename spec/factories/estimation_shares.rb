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

FactoryBot.define do
  factory :estimation_share do
    estimation

    # Default to pending with email
    shared_with_user { nil }
    sequence(:shared_with_email) { Faker::Internet.email }

    trait :active do
      shared_with_email { nil }
      association :shared_with_user, factory: :user
    end

    trait :pending do
      shared_with_user { nil }

      after(:build) do |share|
        share.shared_with_email ||= Faker::Internet.email
      end
    end

    trait :accessed do
      last_accessed_at { 1.hour.ago }
    end
  end
end
