module ConnectionsHelper
  def lead_li_style(lead)
    if lead.try(:status_id) == Lead::COMPLETED_STATUS_ID
      'display: none;'
    else
      ''
    end
  end

  def number_of_survey_responses_not_yet_being_followed_up(survey)
    if survey.responses_count_cache.present? && survey.responses_count_cache > 0
      %(<span class="muted">(#{ survey.responses_count_cache - survey.leads.count })</span>).html_safe
    else
      ''
    end
  end

  def lead_labels(lead_or_response)
    if lead_or_response.is_a?(Lead)
      lead = lead_or_response
      response = lead.response
    else
      response = lead_or_response
      lead = response.lead
    end
    return '' unless lead.present?
    labels = ''
    labels += "<span class='label label-inverse'>#{ response.school.to_s_shorter }</span> " if response.school.present?
    labels += "<span class='label #{ lead.status.gsub(" ", "") }'>#{ lead.status }</span> "
    labels.html_safe
  end
end
