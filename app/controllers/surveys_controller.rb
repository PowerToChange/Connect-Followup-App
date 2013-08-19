class SurveysController < ApplicationController
  before_filter :authenticate_user!

  def show
    @survey = Survey.find(params[:id])
    response_ids_with_leads = Lead.all.collect(&:response_id)
    @responses = @survey.responses(filters).select { |response| !response_ids_with_leads.include?(response.id) }.shuffle
  end

  private

  def filters
    (params[:filters] || {}).select { |key, value| value.present? }
  end
end
