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

module EstimationsHelper
  # An estimate figure as the UI shows it: three significant digits and no
  # trailing ".0" (12.3, 1230, 0).
  def rounded_estimate(value)
    value.to_fs(:rounded, significant: true).gsub(/\.0+$/, '')
  rescue StandardError
    '0'
  end

  # The row partial for an item, by the estimation's mode.
  def estimation_items_partial(estimation)
    if estimation.tracking_mode?
      'estimation_items/estimation_item_trackable'
    else
      'estimation_items/estimation_item'
    end
  end

  def buffer_health_percentage(estimation)
    number_to_percentage(estimation.buffer_health * 100, precision: 0)
  end

  def buffer_health_class(estimation)
    case estimation.buffer_health
    when 0...0.8
      'has-text-success'
    when 0.8...1.0
      'has-text-warning'
    else
      'has-text-danger'
    end
  end
end
