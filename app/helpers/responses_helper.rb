module ResponsesHelper
  def activity_icon(activity)
    icon_class = case activity.activity_type_id
    when ActivityType::PHONE_CALL_TYPE_ID
      "icon-phone"
    when ActivityType::REJOICEABLE_TYPE_ID
      "icon-certificate"
    else
      nil
    end

    # Survey
    icon_class = (Survey.all.collect(&:activity_type_id).include?(activity.activity_type_id.to_i) ? "icon-file-alt" : nil) unless icon_class
    # Email
    icon_class = (activity.activity_name.downcase.include?('email') ? "icon-envelope" : nil) unless icon_class

    %(<i class="#{icon_class} icon-large" />).html_safe
  end

  def activity_details(activity)
    details = []
    if activity.activity_type_id == ActivityType::REJOICEABLE_TYPE_ID
      details << OptionValue.label_for(option_group_id: OptionGroup::REJOICEABLES_ID, value: activity.custom_143)
    end
    details << activity.subject if activity.subject.present?
    details << activity.details if activity.details.present?
    simple_format details.join("<br>")
  end
end
