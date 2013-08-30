module ResponsesHelper
  include ActivitiesHelper

  def lead_report_description(lead)
    if lead.completed? && lead.engagement_level.present?
      "#{ Lead.REPORT_OUTCOMES_GROUPED_BY_ID[lead.engagement_level.to_i][:description].humanize }."
    else
      ''
    end
  end

  def gender_label(gender_id)
    Response.GENDERS.detect { |_, value| value.to_i == gender_id.to_i }.try(:[], 0)
  end

  def year_label(year_id)
    a_year_field = Field.where(field_name: CiviCrm.custom_fields.contact.year).first
    return year_id unless a_year_field.present?
    a_year_field.label_for_option_value(year_id)
  end

  def priority_label(priority_id)
    priority_label = Response.PRIORITIES.detect { |_, value| value.to_i == priority_id.to_i }.try(:[], 0).presence || t('responses.priorities.mild')
    label_class = case priority_label
    when t('responses.priorities.hot')
      'label-important'
    when t('responses.priorities.medium')
      'label-warning'
    else
      'label-info'
    end
    %(<span class="label #{ label_class }">#{ priority_label }</span>).html_safe
  end

  def answer_label(field, value)
    case field
    when CiviCrm.custom_fields.contact.year
      year_label(value)
    when :gender_id
      gender_label(value)
    else
      value
    end
  end
end
