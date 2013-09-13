class LeadsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_survey_and_lead, except: [:create]

  def index
    redirect_to connections_path
  end

  def show
    redirect_to survey_contact_response_path(survey_id: @lead.survey_id, contact_id: @lead.contact_id, id: @lead.response_id)
  end

  def create
    @survey = Survey.find(params[:survey_id])
    @lead = @survey.leads.new(params[:lead])
    @lead.user_id = current_user.id

    if @lead.save
      flash[:notice] = t('leads.create.success')
    elsif Lead.where(response_id: @lead.response_id).present?
      flash[:error] = t('leads.create.error.taken')
    else
      flash[:error] = t('leads.create.error.generic')
    end

    respond_to do |format|
      format.html do
        redirect_to survey_contact_response_path(survey_id: @lead.survey_id, contact_id: @lead.contact_id, id: @lead.response_id)
      end
      format.js {}
    end
  end

  def update
    respond_to do |format|
      format.html do
        if updateable?
          @lead.update_attributes(params[:lead])
          redirect_to survey_lead_path(@lead), notice: t('leads.update.success')
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
          flash[:notice] = t('leads.update.success') unless @lead.completed?
        elsif !updateable?
          # Redirect to the contact completed report without updating the contact to completed
          render inline: "window.location = '#{ report_survey_lead_path(@lead.survey, @lead) }';"
        else
          flash[:error] = t('leads.update.error')
        end
      end
    end
  end

  def destroy
    if @lead.destroy
      flash[:notice] = t('leads.destroy.success')
    else
      flash[:error] = t('leads.destroy.error')
    end

    respond_to do |format|
      format.html do
        redirect_to survey_contact_response_path(survey_id: @lead.survey_id, contact_id: @lead.contact_id, id: @lead.response_id)
      end
      format.js {}
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
    @lead = Lead.find(params[:id]) if params[:id].present?
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = t('error')
    redirect_to connections_path
  end
end
