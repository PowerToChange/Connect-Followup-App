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
    Response.GENDERS.select { |_, value| value.to_i == gender_id.to_i }.first.try(:[], 0)
  end

  def year_label(year_id)
    a_year_field = Field.where(field_name: CiviCrm.custom_fields.contact.year).first
    return year_id unless a_year_field.present?
    a_year_field.label_for_option_value(year_id)
  end
end
