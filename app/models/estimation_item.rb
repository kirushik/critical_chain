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

class EstimationItem < ActiveRecord::Base
  include Broadcastable::EstimationItem
  
  belongs_to :estimation

  validates :value, presence: true, :numericality => { :greater_than_or_equal_to => 0 }
  validates :actual_value, :numericality => { :greater_than_or_equal_to => 0, allow_blank: true }
  validates :quantity, presence: true, :numericality => { :greater_than => 0 }

  before_create :set_default_order

  def total
     quantity * value
  end

  private

  def set_default_order
    return if order.present? && order > 0
    
    # Note: This queries maximum order for each new item creation.
    # For bulk inserts, consider using insert_all which bypasses callbacks,
    # or set order explicitly when creating multiple items.
    max_order = estimation&.estimation_items&.maximum(:order) || 0
    self.order = max_order + 1.0
  end
end
