module ResponsesHelper
  include ActivitiesHelper

  def lead_report_description(lead)
    if lead.completed? && lead.engagement_level.present?
      "#{ engagement_level_label(lead.engagement_level) }."
    else
      ''
    end
  end

  def engagement_level_label(engagement_level_id)
    return '' unless engagement_level_id.present?
    Lead.REPORT_OUTCOMES_GROUPED_BY_ID[engagement_level_id.to_i][:description].humanize
  end

  def gender_label(gender_id)
    return '' unless gender_id.present?
    Response.GENDERS.detect { |_, value| value.to_i == gender_id.to_i }.try(:[], 0)
  end

  def year_label(year_id)
    return '' unless year_id.present?
    a_year_field = Field.where(field_name: CiviCrm.custom_fields.contact.year).first
    return year_id unless a_year_field.present?
    a_year_field.label_for_option_value(year_id)
  end

  def priority_label(priority_id, no_markup = false)
    return '' unless priority_id.present?
    priority_label = Response.PRIORITIES.detect { |_, value| value.to_i == priority_id.to_i }.try(:[], 0).presence || t('responses.priorities.mild')
    label_class = case priority_label
    when t('responses.priorities.hot')
      'label-important'
    when t('responses.priorities.medium')
      'label-warning'
    when t('responses.priorities.mild')
      'label-info'
    else
      'label-default'
    end

    return priority_label if no_markup
    %(<span class="label #{ label_class }">#{ priority_label }</span>).html_safe
  end

  def answer_label(field, value)
    return '' unless field.present? && value.present?
    case field
    when CiviCrm.custom_fields.contact.year
      year_label(value)
    when :gender_id
      gender_label(value)
    else
      value
    end
  end

  def status_label(status_id)
    return '' unless status_id.present?
    Lead.PROGRESS_STATUSES.detect { |id, _|  id == status_id.to_i }.try(:[], 1)
  end

  def boolean_label(boolean)
    return '' unless boolean.present?
    boolean == true || boolean.to_i == 1 ? 'Yes' : 'No'
  end
end
