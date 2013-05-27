class ResponsesController < ApplicationController
  def show
    survey = Survey.find(params[:survey_id])
    @response = Response.find(:survey => survey, :id => params[:id])
  end
end
