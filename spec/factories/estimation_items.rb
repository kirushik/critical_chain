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
#  actual_value  :float
#  order         :float            default(0.0), not null
#
# Indexes
#
#  index_estimation_items_on_estimation_id            (estimation_id)
#  index_estimation_items_on_estimation_id_and_order  (estimation_id,order)
#

FactoryBot.define do
  factory :estimation_item do
    sequence(:value) { Faker::Number.number(digits: 2) }
    sequence(:title) { Faker::Lorem.sentence }
    fixed { false }
    quantity { 1 }

    estimation
  end
end
