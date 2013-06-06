class LeadsController < ApplicationController
  before_filter :authenticate_user!

  def create
    @survey = Survey.find(params[:survey_id])
    @lead = @survey.leads.new(params[:lead])
    @lead.user_id = current_user.id
    if @lead.save
      redirect_to @survey, :notice => "Successfully added lead to your connections list."
    else
      redirect_to @survey, :alert => "Problem adding lead to your connections. Please try again."
    end
  end

  def update
    @lead = Lead.find(params[:id])
    @lead.update_attributes(params[:lead])
    if [4,3].include? params[:lead][:status_id].to_i
      redirect_to survey_response_path(@lead.survey,@lead.response_id), :notice => 'Successfully updated progress status.'
    else
      redirect_to report_survey_lead_path(@lead.survey,@lead)
    end
  end

  def report
    @lead = Lead.find(params[:id])
    @response = Response.find(:survey => @lead.survey, :id => @lead.response_id)
  end
end
