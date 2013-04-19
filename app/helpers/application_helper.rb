module ApplicationHelper
  def link_to_icon(icon, url, options = {})
    link_to %(<i class="icon-#{icon}"></i>).html_safe, url, options
  end
end
