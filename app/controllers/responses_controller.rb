class ResponsesController < ApplicationController
  before_filter :authenticate_user!
  def show
    survey = Survey.find(params[:survey_id])
    @response = Response.find(:survey => survey, :id => params[:id])
    @lead = current_user.leads.find_by_response_id(params[:id])
  end
end
