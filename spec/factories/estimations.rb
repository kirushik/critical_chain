# == Schema Information
#
# Table name: estimations
#
#  id            :integer          not null, primary key
#  title         :string
#  user_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  tracking_mode :boolean          default(FALSE), not null
#
# Indexes
#
#  index_estimations_on_user_id  (user_id)
#

FactoryGirl.define do
  factory :estimation do
    sequence(:title) { Faker::Lorem.sentence }
    tracking_mode false
    user

    factory :estimation_with_items do
      transient do
        # TODO Refactor this into a trait with two separate values
        items {{count: 1, size: 10}}
      end

      after(:create) do |estimation, evaluator|
        FactoryGirl.create_list(:estimation_item, evaluator.items[:count], estimation: estimation, value: evaluator.items[:size])
      end
    end
  end
end
