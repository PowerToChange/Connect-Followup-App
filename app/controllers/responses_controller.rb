class ResponsesController < ApplicationController
  before_filter :authenticate_user!, :get_survey_and_response

  def show
    @lead = current_user.leads.find_by_response_id(params[:id])

    @activities = @response.contact.activities.select { |a| a.status_id == Activity::STATUS_COMPLETED_ID }.reverse

    @notes = @response.contact.notes.select { |n| n.note.present? }.reverse

    @rejoiceables_collection = OptionValue.where(option_group_id: OptionGroup::REJOICEABLES_ID, is_active: 1).sort_by(&:value).collect { |ov| [ov.value, ov.label] }
  end

  def create_rejoiceable
    raise 'Invalid params' unless @response.contact_id && params[:rejoiceable_id].present? && current_user.civicrm_contact_id


  rescue => e
    Rails.logger.error "Failed to create rejoiceable: #{ e }"
    flash[:error] = 'Oops, could not add the rejoiceable!'
  else
    flash[:success] = 'Added rejoiceable!'
  ensure
    redirect_to action: :show
  end

  def create_note
    raise 'Invalid params' unless @response.contact_id && params[:note].present? && current_user.civicrm_contact_id

    response = CiviCrm::Note.create(
      subject: current_user_stamp,
      note: params[:note],
      entity_id: @response.contact_id,
      contact_id: current_user.civicrm_contact_id
    )
  rescue => e
    Rails.logger.error "Failed to create note: #{ e }"
    flash[:error] = 'Oops, could not add the note!'
  else
    flash[:success] = 'Added note!'
  ensure
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
