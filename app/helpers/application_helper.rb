module ApplicationHelper
  # The <title>: the page's own (`content_for :title`), else the locale's
  # `<controller>.<action>.title`, followed by the app name.
  def page_title
    title = content_for(:title).presence ||
            t("#{controller_path.tr('/', '.')}.#{action_name}.title", default: nil)
    safe_join([title, t('app.name')].compact, ' - ')
  end

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
