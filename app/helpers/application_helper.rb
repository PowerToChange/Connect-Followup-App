module ApplicationHelper
  def link_to_icon(icon, url, options = {})
    link_to %(<i class="icon-#{icon} icon-large"></i>).html_safe, url, options
  end
  def link_to_phone(icon, option, tel=nil)
    link_to_icon icon, tel.present? ? "#{option}:#{tel}" : "javascript:void(0)", class: "btn #{'disabled' if tel.blank?}"
  end
end
