class EstimationDecorator < Draper::Decorator
  decorates :estimation
  delegate_all

  include ActionView::Helpers::NumberHelper

  def estimation_items
    object.estimation_items.order(:created_at)
  end

  def sum
    # TODO Replace whose with a proper number helper
    object.sum.to_s(:rounded, significant: true).gsub(/\.0+$/, '') rescue "0"
  end

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

  def buffer_health
    number_to_percentage(object.buffer_health*100, precision: 0)
  end

  def buffer_health_class
    case object.buffer_health
    when 0...0.8
      'bg-success'
    when 0.8...1.0
      'bg-warning'
    else
      'bg-danger'
    end
  end
end
