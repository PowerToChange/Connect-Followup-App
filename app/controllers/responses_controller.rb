class ResponsesController < ApplicationController
  before_filter :authenticate_user!
  def show
    survey = Survey.find(params[:survey_id])
    @response = Response.find(:survey => survey, :id => params[:id])
    @lead = current_user.leads.find_by_response_id(params[:id])
    @activities = @response.contact.activities.select { |a| a.status_id == Activity::STATUS_COMPLETED_ID }.reverse
  end
end
