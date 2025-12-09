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
  has_many :estimation_items, -> { order(:order) }, dependent: :destroy
  has_many :estimation_shares, dependent: :destroy

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
    progress = completed_items.sum('value * quantity')/sum
    progress > 0 ? progress : 0.0
  end

  def buffer_consumption
    actual_consumption = (completed_items.sum(:actual_value) - completed_items.sum('value * quantity'))/buffer
    actual_consumption > 0 ? actual_consumption : 0.0
  end

  def buffer_health
    health = buffer_consumption/project_progress
    health.nan? ? 0.0 : health
  end

  def shared_with?(user)
    return false if user.nil?
    estimation_shares.for_user(user).exists?
  end

  def share_for(user)
    return nil if user.nil?
    estimation_shares.for_user(user).first
  end

  def can_edit?(user)
    return false if user.nil?
    self.user == user
  end

  def can_view?(user)
    return false if user.nil?
    can_edit?(user) || shared_with?(user)
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
