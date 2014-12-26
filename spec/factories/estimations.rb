# == Schema Information
#
# Table name: estimations
#
#  id         :integer          not null, primary key
#  title      :string
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_estimations_on_user_id  (user_id)
#

FactoryGirl.define do
  factory :estimation do
    sequence(:title) { Faker::Lorem.sentence }

    factory :estimation_with_items do
      transient do
        estimation_items 2
        item_size 117
      end

      after(:create) do |estimation, evaluator|
        FactoryGirl.create_list(:estimation_item, evaluator.estimation_items, estimation: estimation, value: evaluator.item_size)
      end
    end
  end
end
