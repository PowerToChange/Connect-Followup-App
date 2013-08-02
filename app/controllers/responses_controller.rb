class ResponsesController < ApplicationController
  respond_to :html, :json
  before_filter :authenticate_user!, :get_survey_and_response

  def show
    @lead = current_user.leads.find_by_response_id(params[:id])

    contact = Contact.where(id: @response.contact_id).includes(:notes, :activities).first
    @activities = contact.activities.select { |a| a.status_id == Activity::STATUS_COMPLETED_ID }.reverse
    @notes = contact.notes.select { |n| n.note.present? }.reverse

    @rejoiceables_collection = OptionValue.where(option_group_id: OptionGroup::REJOICEABLES_ID, is_active: 1).sort_by(&:value).collect { |ov| [ov.value, ov.label] }
  end

  def create
    params[:activity].merge!({
      source_contact_id: @response.contact_id,
      status_id: Lead::COMPLETED_STATUS_ID,
      details: current_user.to_s,
      target_contact_id: current_user.civicrm_id
    })
    @activity = Activity.new(params[:activity])

    path = survey_response_path(@survey.id, @response.response_id)

    respond_with(@activity, location: survey_response_path(@survey,@response)) do |format|
      if @activity.save
        format.html do
          flash[:success] = 'Activity successfully created.'
          redirect_to path
        end
        format.json do
          head :ok
        end
      else
        format.html do
          flash[:error] =  'Oops, could not add activity!'
          redirect_to path
        end
      end
    end
  end

  def create_note
    new_note = Note.new(
      subject: current_user.to_s,
      note: params[:note],
      # We need to set both entity_id and contact_id in order for API chaining to work properly, this appears to be a bug in CiviCrm?
      entity_id: @response.contact_id,
      contact_id: @response.contact_id
    )

    if new_note.save
      flash[:success] = 'Added note!'
    else
      flash[:error] = 'Oops, could not add the note!'
    end

    redirect_to action: :show
  end

  private

  def get_survey_and_response
    @survey = Survey.find(params[:survey_id])
    @response = Response.find(:survey => @survey, :id => params[:id])
  end
end
