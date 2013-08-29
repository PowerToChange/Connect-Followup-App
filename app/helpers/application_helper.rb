module ApplicationHelper
  def link_to_icon(icon, url, options = {})
    content = %(<i class="icon icon-#{ icon } icon-large"></i>)
    content = %(#{ content }&nbsp;#{ options[:label] }) if options[:label].present?
    content = %(#{ options[:prelabel] }&nbsp;#{ content }) if options[:prelabel].present?
    content = %(#{ content }<span class="hidden-phone">&nbsp;#{ options[:label_hidden_phone] }</span>) if options[:label_hidden_phone].present?
    link_to content.html_safe, url, options
  end

  def link_to_phone(icon, option, tel=nil)
    link_to_icon icon, tel.present? ? "#{option}:#{tel}" : "javascript:void(0)", class: "btn #{'disabled' if tel.blank?}"
  end

  def days_ago_in_words(date)
    return '' unless date.present?
    date = date.is_a?(String) ? date : date.to_s
    days = (Time.now.to_date - Date.parse(date)).to_i

    if days <= 0
      t('today')
    elsif days == 1
      t('yesterday')
    else
      t('days_ago_in_words', days: days)
    end
  end

  def contact_image_tag(contact)
    gravatar_image_tag(contact.email, gravatar: { default: "#{ request.protocol }#{ request.host_with_port }#{ asset_path('no_photo.png') }" }, class: 'img-circle')
  end
end
