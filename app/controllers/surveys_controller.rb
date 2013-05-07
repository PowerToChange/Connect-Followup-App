class SurveysController < ApplicationController
  def index
    @activities = Array(CiviCrm::Activity.find(:activity_type_id => 32))
  end
end
