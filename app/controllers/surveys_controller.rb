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
    (params[:filters] || {}).select { |key, value| value.present? }
  end
end
