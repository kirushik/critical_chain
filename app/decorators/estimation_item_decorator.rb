class EstimationItemDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def editable field, type: :text, css_class: nil
    helpers.editable object, field, url: helpers.estimation_estimation_item_path(object.estimation, object), type: type, css_class: css_class || field
  end
end
