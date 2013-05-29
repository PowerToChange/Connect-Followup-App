class SurveysController < ApplicationController
  before_filter :authenticate_user!
  def index
    @surveys = current_user.surveys.all
  end
end
