# == Schema Information
#
# Table name: estimation_items
#
#  id            :integer          not null, primary key
#  value         :integer
#  title         :string
#  estimation_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_estimation_items_on_estimation_id  (estimation_id)
#

FactoryGirl.define do
  factory :estimation_item do
    sequence(:value) { Faker::Number.number(2) }
    sequence(:title) { Faker::Lorem.sentence }
  end
end
