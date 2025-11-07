module EditableHelper
  # Helper to create x-editable elements
  # This replaces the helper from the removed x-editable-rails gem
  def editable(object, field, options = {})
    value = object.send(field)
    value = options[:placeholder] || 'Empty' if value.nil? || value.to_s.empty?

    url = options[:url]
    mode = options[:mode] || 'inline'
    type = options[:type] || 'text'
    css_class = options[:class] || field.to_s

    data_attrs = {
      type: type.to_s,
      mode: mode.to_s,
      url: url,
      name: field.to_s,
      pk: object.id,
      value: value
    }

    data_attrs[:placeholder] = options[:placeholder] if options[:placeholder]
    data_attrs[:source] = options[:source].to_json if options[:source]
    data_attrs[:title] = options[:title] if options[:title]

    content_tag(:span, value, class: "editable #{css_class}", data: data_attrs, id: "editable_#{object.class.name.underscore}_#{object.id}_#{field}")
  end
end
