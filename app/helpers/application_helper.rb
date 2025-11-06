module ApplicationHelper
  def icon(icon_name, text = nil, html_options = {})
    # Extract icon name and additional classes
    parts = icon_name.split(' ')
    name = parts.first
    additional_classes = parts[1..-1].join(' ')
    
    # Font Awesome 6 uses 'fa-brands' for brand icons like google
    # and 'fa-solid' for regular icons
    style_class = case name
    when 'google', 'facebook', 'twitter', 'github', 'linkedin'
      'fa-brands'
    else
      'fa-solid'
    end
    
    # Build the icon HTML
    icon_class = [style_class, "fa-#{name}", additional_classes].join(' ').strip
    icon_html = content_tag(:i, '', class: icon_class)
    
    # Add text if provided
    if text
      icon_html + ' ' + text
    else
      icon_html
    end
  end
end
