module EditableHelper
  # Helper to create Stimulus-powered editable elements
  def editable(object, field, options = {})
    value = object.send(field)
    value = options[:placeholder] || 'Empty' if value.nil? || value.to_s.empty?

    url = options[:url]
    type = options[:type] || 'text'
    css_class = options[:class] || field.to_s

    content_tag(:span,
                class: "editable #{css_class}",
                id: "editable_#{object.class.name.underscore}_#{object.id}_#{field}",
                data: {
                  controller: 'editable',
                  action: 'click->editable#edit',
                  editable_url_value: url,
                  editable_name_value: field.to_s,
                  editable_type_value: type.to_s,
                  editable_pk_value: object.id,
                  editable_model_value: object.class.name.underscore,
                  editable_target: 'field'
                }) do
      content_tag(:span, value, 
                  class: 'editable-display',
                  data: { editable_target: 'display' }, 
                  style: 'cursor: pointer;')
    end
  end
end
