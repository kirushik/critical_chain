module ApplicationHelper
  BRAND_ICONS = %w[google facebook twitter github linkedin].freeze
  
  def icon(icon_name, text = nil)
    return '' if icon_name.blank?
    
    # Extract icon name and additional classes
    parts = icon_name.split(' ')
    name = parts.first
    additional_classes = parts[1..-1].join(' ')
    
    # Font Awesome 6 uses 'fa-brands' for brand icons like google
    # and 'fa-solid' for regular icons
    style_class = BRAND_ICONS.include?(name) ? 'fa-brands' : 'fa-solid'
    
    # Build the icon HTML
    icon_class = [style_class, "fa-#{name}", additional_classes].reject(&:empty?).join(' ')
    icon_html = content_tag(:i, '', class: icon_class)
    
    # Add text if provided (properly escaped)
    if text
      safe_join([icon_html, text], ' ')
    else
      icon_html
    end
  end
end
