module ApplicationHelper
  def schools_associated_to_current_user_and_to_survey
    @survey.present? ? @survey.schools & current_user.schools : current_user.schools
  end

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
  
  def pulse_profile
    the_link = "https://pulse.p2c.com/people/"
    the_link += current_user.pulse_id.to_s if current_user.pulse_id.present?
    the_link
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

  # This helper can be used to cache an entire method by wrapping the method in a block passed to this helper
  # The cache key will be based on the name of the method, the method's class, and the method's arguments (local variables)
  def cache_method(caller_binding, &block)
    locals = caller_binding.eval('local_variables').collect { |local| "#{ local }=#{ caller_binding.eval("#{ local.to_s }.inspect") }" }
    Rails.cache.fetch([caller_binding.eval('self.class.name'), locals]) { block.call }
  end
end
