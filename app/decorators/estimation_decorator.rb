class EstimationDecorator < Draper::Decorator
  decorates :estimation
  delegate_all

  def buffer
    object.buffer.to_s(:rounded, significant: true).gsub(/\.0+$/, '') rescue "0"
  end

  def total
    object.total.to_s(:rounded, significant: true).gsub(/\.0+$/, '') rescue "0"
  end

end
