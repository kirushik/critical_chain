class EstimationDecorator < Draper::Decorator
  decorates :estimation
  delegate_all

  def buffer
    object.buffer.to_s(:rounded, significant: true).gsub(/\.0+$/, '') rescue "0"
  end

  def total
    object.total.to_s(:rounded, significant: true).gsub(/\.0+$/, '') rescue "0"
  end

  def items_partial_name
    if tracking_mode?
      'estimation_items/estimation_item_trackable'
    else
      'estimation_items/estimation_item'
    end
  end

  def actual_sum
    object.estimation_items.sum(:actual_value)
  end
end
