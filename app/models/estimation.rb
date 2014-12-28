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

class Estimation < ActiveRecord::Base
  belongs_to :user
  has_many :estimation_items, dependent: :destroy

  def sum
    estimation_items.pluck(:value).sum
  end

  def buffer
    sum/Math.sqrt(estimation_items.count)
  end

  def total
    sum + buffer
  end
end
