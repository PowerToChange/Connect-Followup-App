class SurveysController < ApplicationController
  before_filter :authenticate_user!, :get_survey

  def show
    response_ids_with_leads = Lead.all.collect(&:response_id)
    @responses = @survey.responses(filters).select { |response| !response_ids_with_leads.include?(response.id) }.shuffle
  end

  def all
    @responses = @survey.responses.sort_by { |r| r.contact.display_name }
  end

  private

  def get_survey
    @survey = Survey.find(params[:id])
  end

  def filters
    params[:filters] = (params[:filters].presence || default_filter).select { |_, value| value.present? }
    params[:filters].each { |key, value| cookies[filter_cookie_key(key)] = value }
    params[:filters]
  end

  def default_filter
    # We want to limit the default result set
    { target_contact_relationship_contact_id_b: cookies[filter_cookie_key(:target_contact_relationship_contact_id_b)] || schools_associated_to_current_user_and_to_survey.first.try(:civicrm_id) }
  end

  def schools_associated_to_current_user_and_to_survey
    @survey.schools & current_user.schools
  end

  def filter_cookie_key(filter)
    "filter_#{ filter }_for_survey_#{ @survey.id }"
  end
end
