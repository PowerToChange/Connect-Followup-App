class ActivitiesController < ApplicationController
  include ActivitiesHelper

  before_filter :authenticate_user!, :initialize_lead

  def create
    params[:activity].merge!({
      source_contact_id: current_user.civicrm_id,
      status_id: Activity::STATUS_COMPLETED_ID,
      details: current_user.to_s,
      target_contact_id: params[:contact_id]
    })
    @activity = Activity.new(params[:activity])

    activity_name = activity_name(@activity.activity_type_id)

    if @activity.save
      flash[:success] = "#{ activity_name } added!"
    else
      flash[:error] =  "Oops, could not add #{ activity_name.downcase }!"
    end
  end

  private

  def render *args
    create_lead # This affects the view so we need to run it before rendering (an after_filter isn't good enough)
    super
  end

  def initialize_lead
    @lead = Lead.where(response_id: params[:response_id], contact_id: params[:contact_id], user_id: current_user.id, survey_id: params[:survey_id]).first_or_initialize
  end

  def create_lead
    # Automatically create a lead if this response is not already assigned to a user
    return unless @activity.persisted? # Abort if the activity wasn't saved

    if @lead.uncontacted?
      flash[:success] += " This contact has now been added to your connections." if @lead.new_record?
      @lead.in_progress.save
    end
  end

end