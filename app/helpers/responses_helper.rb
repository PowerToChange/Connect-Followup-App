module ResponsesHelper
  include ActivitiesHelper

  def lead_report_description(lead)
    if lead.completed? && lead.engagement_level.present?
      "#{ Lead::REPORT_OUTCOMES_GROUPED_BY_ID[lead.engagement_level.to_i][:description].humanize }."
    else
      ''
    end
  end
end
