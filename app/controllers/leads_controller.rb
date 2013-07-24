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
    respond_to do |format|
      format.html do
        if updateable?
          @lead.update_attributes(params[:lead])
          redirect_to survey_response_path(@lead.survey,@lead.response_id), :notice => 'Successfully updated progress status.'
        else
          redirect_to report_survey_lead_path(@lead.survey,@lead)
        end
      end
      format.json do
        if @lead.update_attributes(params[:lead])
          render :json => { engagement_level: @lead.engagement_level }
        else
          render :json => @lead.errors.full_messages.join(','), :status => 400
        end
      end
    end
  end

  def report
    @lead = Lead.find(params[:id])
    @response = Response.find(:survey => @lead.survey, :id => @lead.response_id)
  end

  private

  def updateable?
    [4,3].include?(params[:lead][:status_id].to_i)
  end
end
