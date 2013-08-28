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

  def lead_labels(lead)
    return '' unless lead.present?
    "<span class='label status-#{ lead.status_id }'>#{ lead.status }</span> ".html_safe
  end

  def response_labels(response)
    return '' unless response.present?
    labels = ''
    labels += "<span class='label label-inverse'>#{ response.school.to_s_shorter }</span> " if response.school.present?
    labels += priority_label(response.response.priority_id)
    labels.html_safe
  end
end
