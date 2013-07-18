module ApplicationHelper
  def link_to_icon(icon, url, options = {})
    content = %(<i class="icon-#{ icon } icon-large"></i>)
    content = %(#{ content }<span class="hidden-phone">&nbsp;#{ options[:label_hidden_phone] }</span>) if options[:label_hidden_phone].present?
    link_to content.html_safe, url, options
  end

  def link_to_phone(icon, option, tel=nil)
    link_to_icon icon, tel.present? ? "#{option}:#{tel}" : "javascript:void(0)", class: "btn #{'disabled' if tel.blank?}"
  end
end
