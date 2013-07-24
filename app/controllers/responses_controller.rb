class ResponsesController < ApplicationController
  before_filter :authenticate_user!, :get_survey_and_response

  def show
    @lead = current_user.leads.find_by_response_id(params[:id])

    @activities = @response.contact.activities.select { |a| a.status_id == Activity::STATUS_COMPLETED_ID }.reverse

    @notes = @response.contact.notes.select { |n| n.note.present? }.reverse

    @rejoiceables_collection = OptionValue.where(option_group_id: OptionGroup::REJOICEABLES_ID, is_active: 1).sort_by(&:value).collect { |ov| [ov.value, ov.label] }
  end

  def create_rejoiceable
    new_rejoiceable = Rejoiceable.new(
      source_contact_id: @response.contact_id,
      activity_type_id: ActivityType::REJOICEABLE_TYPE_ID,
      status_id: Lead::COMPLETED_STATUS_ID,
      custom_143: params[:rejoiceable_id],
      details: current_user_stamp,
      target_contact_id: current_user.civicrm_contact_id
    )
    if new_rejoiceable.save
      flash[:success] = 'Added rejoiceable!'
    else
      flash[:error] = 'Oops, could not add the rejoiceable!'
    end

    redirect_to action: :show
  end

  def create_note
    new_note = Note.create(
      subject: current_user_stamp,
      note: params[:note],
      entity_id: @response.contact_id,
      contact_id: current_user.civicrm_contact_id
    )

    if new_note.save
      flash[:success] = 'Added note!'
    else
      flash[:error] = 'Oops, could not add the note!'
    end

    redirect_to action: :show
  end

  private

  def current_user_stamp
    current_user.email
  end

  def get_survey_and_response
    @survey = Survey.find(params[:survey_id])
    @response = Response.find(:survey => @survey, :id => params[:id])
  end
end
