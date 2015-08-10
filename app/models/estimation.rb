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

class Estimation < ActiveRecord::Base
  belongs_to :user
  has_many :estimation_items, dependent: :destroy

  def sum
    estimation_items.sum('value * quantity').to_f
  end

  def buffer
    bufferable_sum/Math.sqrt(bufferable_count)
  end

  def total
    sum + buffer
  end

  def completed_items
    estimation_items.where.not(actual_value: nil)
  end

  def project_progress
    completed_items.sum('value * quantity')/sum
  end

  def buffer_consumption
    [(completed_items.sum(:actual_value) - completed_items.sum('value * quantity'))/buffer, 0].max
  end

  def buffer_consumption_health
    health = buffer_consumption/project_progress
    health.nan? ? 0 : health
  end

  private
  def bufferable_sum
    #TODO Make this a scope
    estimation_items.where(fixed: false).sum('value * quantity')
  end

  def bufferable_count
    #TODO Make this a scope
    count = estimation_items.where(fixed: false).sum(:quantity)
    count == 0 ? 1 : count
  end
end
