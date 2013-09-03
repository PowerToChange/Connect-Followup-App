class SurveysController < ApplicationController
  before_filter :authenticate_user!, :get_survey

  def show
    @responses = @survey.responses(filters.merge(assignee_contact_id: 'NULL')).shuffle
  end

  def all
    @responses = @survey.responses(filters).sort_by { |r| r.contact.try(:display_name).try(:downcase) }
  end

  private

  def get_survey
    @survey = Survey.find(params[:id])
  end
end
