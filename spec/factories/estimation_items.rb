# == Schema Information
#
# Table name: estimation_items
#
#  id            :integer          not null, primary key
#  actual_value  :float
#  fixed         :boolean          default(FALSE), not null
#  order         :float            default(0.0), not null
#  quantity      :integer          default(1), not null
#  title         :string
#  value         :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  estimation_id :integer
#
# Indexes
#
#  index_estimation_items_on_estimation_id            (estimation_id)
#  index_estimation_items_on_estimation_id_and_order  (estimation_id,order)
#
# Foreign Keys
#
#  estimation_id  (estimation_id => estimations.id)
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
