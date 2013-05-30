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
end
