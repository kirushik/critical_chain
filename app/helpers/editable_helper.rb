module EditableHelper
  # Helper to create Stimulus-powered editable elements with pre-rendered form
  def editable(object, field, options = {})
    value = object.send(field)
    display_value = value.nil? || value.to_s.empty? ? (options[:placeholder] || 'Empty') : value

    url = options[:url]
    type = options[:type] || 'text'
    css_class = options[:class] || field.to_s
    field_id = "editable_#{object.class.name.underscore}_#{object.id}_#{field}"

    content_tag(:div,
                class: "editable-field #{css_class}",
                id: field_id,
                data: {
                  controller: 'editable',
                  editable_target: 'field'
                }) do
      # Display state (visible by default)
      display = content_tag(:span,
                           h(display_value),
                           class: 'editable-display',
                           data: {
                             action: 'click->editable#edit',
                             editable_target: 'display'
                           },
                           style: 'cursor: pointer;',
                           title: 'Click to edit')

      # Edit form (hidden by default) using Bootstrap 4 input-group
      edit_form = form_tag(url,
                          method: :patch,
                          class: 'editable-form',
                          data: {
                            turbo_stream: true,
                            editable_target: 'form'
                          }) do
        # Use Bootstrap 4 input-group to attach buttons inline
        content_tag(:div, class: 'input-group input-group-sm') do
          field_name = "#{object.class.name.underscore}[#{field}]"
          # Generate unique input ID to avoid collisions with "add new item" forms
          input_id = "#{object.class.name.underscore}_#{object.id}_#{field}"

          field_options = {
            id: input_id,
            class: 'form-control',
            data: {
              action: 'keydown->editable#handleKeydown',
              editable_target: 'input'
            }
          }

          input_field = if type.to_s == 'number'
            number_field_tag(field_name, value, field_options)
          else
            text_field_tag(field_name, value, field_options)
          end

          # Append buttons using input-group-append
          safe_join([
            input_field,
            content_tag(:div, class: 'input-group-append') do
              safe_join([
                button_tag(type: 'submit',
                          class: 'btn btn-success editable-submit',
                          title: 'Save changes',
                          aria: { label: 'Save' }) do
                  content_tag(:i, '', class: 'fa fa-check')
                end,
                button_tag(type: 'button',
                          class: 'btn btn-default editable-cancel',
                          data: { action: 'click->editable#cancel' },
                          title: 'Cancel editing',
                          aria: { label: 'Cancel' }) do
                  content_tag(:i, '', class: 'fa fa-times')
                end
              ])
            end
          ])
        end
      end

      safe_join([display, edit_form])
    end
  end
end
