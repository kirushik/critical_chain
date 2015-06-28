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
#  fixed         :boolean          default(FALSE), not null
#  quantity      :integer          default(1), not null
#
# Indexes
#
#  index_estimation_items_on_estimation_id  (estimation_id)
#

FactoryGirl.define do
  factory :estimation_item do
    value { Faker::Number.number(2) }
    title { Faker::Lorem.sentence }
    fixed false

    estimation
  end
end
