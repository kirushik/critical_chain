module EditableHelper
  # Helper to create Stimulus-powered editable elements with pre-rendered form
  def editable(object, field, options = {})
    value = object.send(field)
    display_value = value.nil? || value.to_s.empty? ? (options[:placeholder] || 'Empty') : value

    url = options[:url]
    type = options[:type] || 'text'
    css_class = options[:css_class] || field.to_s
    field_id = "editable_#{object.class.name.underscore}_#{object.id}_#{field}"

    can_edit = if options.key?(:can_edit)
                 options[:can_edit]
               else
                 editable_by_current_user?(object)
               end

    unless can_edit
      return content_tag(:div,
                         class: "editable-field #{css_class} is-readonly",
                         id: field_id) do
        content_tag(:span,
                    h(display_value),
                    class: 'editable-display')
      end
    end

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

      # Edit form (hidden by default) using Bulma field/control structure
      edit_form = form_tag(url,
                          method: :patch,
                          class: 'editable-form',
                          data: {
                            turbo_stream: true,
                            editable_target: 'form',
                            action: 'submit->editable#handleSubmit'
                          }) do
        # Use Bulma field/control structure with has-addons for inline buttons
        content_tag(:div, class: 'field has-addons is-small') do
          field_name = "#{object.class.name.underscore}[#{field}]"
          # Generate unique input ID to avoid collisions with "add new item" forms
          input_id = "#{object.class.name.underscore}_#{object.id}_#{field}"

          field_options = {
            id: input_id,
            class: 'input is-small',
            data: {
              action: 'keydown->editable#handleKeydown blur->editable#handleBlur',
              editable_target: 'input'
            }
          }

          input_field = if type.to_s == 'number'
            number_field_tag(field_name, value, field_options)
          else
            text_field_tag(field_name, value, field_options)
          end

          # Wrap input and buttons in Bulma controls
          safe_join([
            content_tag(:div, class: 'control') do
              input_field
            end,
            content_tag(:div, class: 'control') do
              button_tag(type: 'submit',
                        class: 'button is-success is-small editable-submit',
                        title: 'Save changes',
                        aria: { label: 'Save' }) do
                content_tag(:span, class: 'icon is-small') do
                  content_tag(:i, '', class: 'fa fa-check')
                end
              end
            end,
            content_tag(:div, class: 'control') do
              button_tag(type: 'button',
                        class: 'button is-light is-small editable-cancel',
                        data: { action: 'click->editable#cancel' },
                        title: 'Cancel editing',
                        aria: { label: 'Cancel' }) do
                content_tag(:span, class: 'icon is-small') do
                  content_tag(:i, '', class: 'fa fa-times')
                end
              end
            end
          ])
        end
      end

      safe_join([display, edit_form])
    end
  end

  private

  def editable_by_current_user?(object)
    user = respond_to?(:current_user) ? current_user : nil
    return true if user.nil?

    estimation = object.respond_to?(:estimation) ? object.estimation : nil

    if object.respond_to?(:can_edit?)
      object.can_edit?(user)
    elsif estimation && estimation.respond_to?(:can_edit?)
      estimation.can_edit?(user)
    elsif respond_to?(:policy)
      begin
        policy_object = policy(object)
        policy_object.nil? || !policy_object.respond_to?(:update?) || policy_object.update?
      rescue StandardError
        true
      end
    else
      true
    end
  end
end
