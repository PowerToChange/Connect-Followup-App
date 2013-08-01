module ApplicationHelper
  def link_to_icon(icon, url, options = {})
    content = %(<i class="icon-#{ icon } icon-large"></i>)
    content = %(#{ content }<span class="hidden-phone">&nbsp;#{ options[:label_hidden_phone] }</span>) if options[:label_hidden_phone].present?
    link_to content.html_safe, url, options
  end

  def link_to_phone(icon, option, tel=nil)
    link_to_icon icon, tel.present? ? "#{option}:#{tel}" : "javascript:void(0)", class: "btn #{'disabled' if tel.blank?}"
  end

  def custom_time_ago_in_words(time_str)
    time = time_str.to_time + (-Time.zone_offset(Time.now.zone))
    "#{time_ago_in_words(time)} ago"
  end

  def days_ago(date_str)
    d = Date.parse(date_str)
    days = Time.now.to_date - d
    days.zero? ? 'Today' : "#{days} days ago"
  end

  def contact_image_tag(contact)
    gravatar_image_tag(contact.email, gravatar: { default: "#{ request.protocol }#{ request.host_with_port }#{ asset_path('no_photo.png') }" })
  end
end
