class ActivitiesController < ApplicationController
  include ActivitiesHelper

  before_filter :authenticate_user!

  def create
    params[:activity].merge!({
      source_contact_id: current_user.civicrm_id || User::DEFAULT_CIVICRM_ID,
      status_id: Lead::COMPLETED_STATUS_ID,
      details: current_user.to_s,
      target_contact_id: params[:contact_id]
    })
    @activity = Activity.new(params[:activity])

    activity_name = activity_name(@activity.activity_type_id)

    if @activity.save
      flash[:success] = "#{ activity_name } added."
    else
      flash[:error] =  "Oops, could not add #{ activity_name.downcase }!"
    end
  end

end