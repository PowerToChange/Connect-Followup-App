module ConnectionsHelper
  def lead_li_style(lead)
    if lead.status_id == Lead::COMPLETED_STATUS_ID
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
end
