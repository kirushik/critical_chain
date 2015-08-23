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

  def editable field, type: :text
    helpers.content_tag :input, nil, type: type, value: object.send(field),
      data: { path: helpers.estimation_estimation_item_path(object.estimation, object), field: field, object: :estimation_item },
      id: "#{helpers.dom_id object}_#{field}", class: [:editable, field]
  end
end
