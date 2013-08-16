module ResponsesHelper
  include ActivitiesHelper

  def lead_report_description(lead)
    if lead.completed? && lead.engagement_level.present?
      "#{ Lead::REPORT_OUTCOMES_GROUPED_BY_ID[lead.engagement_level.to_i][:description].humanize }."
    else
      ''
    end
  end

  def gender_label(gender_id)
    Response::GENDERS.select { |_, value| value.to_i == gender_id.to_i }.first.try(:[], 0)
  end

  def year_label(year_id)
    Response::YEARS.select { |_, value| value.to_i == year_id.to_i }.first.try(:[], 0)
  end
end
