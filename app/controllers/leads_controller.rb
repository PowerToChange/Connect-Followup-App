class LeadsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_survey_and_lead, except: [:create]

  def create
    @survey = Survey.find(params[:survey_id])
    @lead = @survey.leads.new(params[:lead])
    @lead.user_id = current_user.id

    if @lead.save
      flash[:notice] = "Added contact to your connections list."
    else
      flash[:error] = "Oops, could not add this contact to your connections!"
    end
  end

  def update
    respond_to do |format|
      format.html do
        if updateable?
          @lead.update_attributes(params[:lead])
          redirect_to survey_lead_path(@lead), notice: 'Updated status.'
        else
          # Redirect to the contact completed report without updating the contact to completed
          redirect_to report_survey_lead_path(@lead.survey,@lead)
        end
      end

      format.json do
        if @lead.update_attributes(params[:lead])
          head :ok
        else
          render json: @lead.errors.full_messages.join(','), status: 400
        end
      end

      format.js do
        if updateable? && @lead.update_attributes(params[:lead])
          flash[:notice] = 'Updated status.' unless @lead.completed?
        elsif !updateable?
          # Redirect to the contact completed report without updating the contact to completed
          render inline: "window.location = '#{ report_survey_lead_path(@lead.survey, @lead) }';"
        else
          flash[:error] = 'Oops, could not update status!'
        end
      end
    end
  end

  def destroy
    if @lead.destroy
      flash[:notice] = 'Released contact from your connections list.'
    else
      flash[:error] = 'Oops, could not release contact from your connections!'
    end
  end

  def report
    @response = Response.find(survey: @lead.survey, id: @lead.response_id)
    @lead.response = @response
  end

  private

  def updateable?
    [4,3].include?(params[:lead][:status_id].to_i)
  end

  def get_survey_and_lead
    @survey = Survey.find(params[:survey_id])
    @lead = Lead.find(params[:id])
  end
end
