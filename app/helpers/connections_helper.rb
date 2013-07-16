module ConnectionsHelper
  def lead_li_style(lead)
    if lead.status_id == Lead::COMPLETED_STATUS_ID
      'display: none;'
    else
      ''
    end
  end
end
