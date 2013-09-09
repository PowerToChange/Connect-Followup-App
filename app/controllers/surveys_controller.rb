class SurveysController < ApplicationController
  before_filter :authenticate_user!, :get_survey

  def show
    @responses = @survey.responses(filters.merge(assignee_contact_id: 'NULL').merge(sort)).shuffle
  end

  def all
    @responses = @survey.responses(filters.merge(sort)).sort_by { |r| r.contact.try(:display_name).try(:downcase) }
  end

  private

  def get_survey
    @survey = Survey.find(params[:id])
  end

  def sort
    { sort: 'priority_id' }
  end
end
