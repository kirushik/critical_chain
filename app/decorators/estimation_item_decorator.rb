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
    current_user = begin
      helpers.current_user
    rescue Devise::MissingWarden
      nil
    end

    helpers.editable object,
                     field,
                     url: helpers.estimation_estimation_item_path(object.estimation, object),
                     type: type,
                     css_class: css_class || field,
                     can_edit: object.estimation.can_edit?(current_user)
  end
end
