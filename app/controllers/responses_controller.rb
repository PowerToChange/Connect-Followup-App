class ResponsesController < ApplicationController
  before_filter :authenticate_user!, :get_survey_and_response

  def show
    @lead = current_user.leads.find_by_response_id(params[:id])

    @activities = @response.contact.activities || []
    @activities = @activities.select { |a| a.status_id == Activity::STATUS_COMPLETED_ID }.reverse if @activities.present?

    @rejoiceables_collection = OptionValue.where(option_group_id: OptionGroup::REJOICEABLES_ID, is_active: 1).sort_by(&:value).collect { |ov| [ov.value, ov.label] }
  end

  def create_rejoiceable
    raise 'Invalid params' unless @response.contact_id && params[:rejoiceable_id] && current_user.civicrm_contact_id

    response = CiviCrm::Activity.create(
      source_contact_id: @response.contact_id,
      activity_type_id: ActivityType::REJOICEABLE_TYPE_ID,
      activity_status_id: Lead::COMPLETED_STATUS_ID,
      custom_143: params[:rejoiceable_id],
      target_contact_id: current_user.civicrm_contact_id
    )
  rescue => e
    Rails.logger.error "Failed to create rejoiceable: #{ e }"
    flash[:error] = 'Oops, could not add the rejoiceable!'
  else
    flash[:success] = 'Added rejoiceable!'
  ensure
    redirect_to action: :show
  end

  private

  def get_survey_and_response
    @survey = Survey.find(params[:survey_id])
    @response = Response.find(:survey => @survey, :id => params[:id])
  end
end
