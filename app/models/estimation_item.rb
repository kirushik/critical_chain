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
#
# Indexes
#
#  index_estimation_items_on_estimation_id  (estimation_id)
#

class EstimationItem < ActiveRecord::Base
  belongs_to :estimation

  validates :value, presence: true, :numericality => { :greater_than_or_equal_to => 0 }
  validates :actual_value, :numericality => { :greater_than_or_equal_to => 0, allow_blank: true }
  validates :quantity, presence: true, :numericality => { :greater_than => 0 }
end
