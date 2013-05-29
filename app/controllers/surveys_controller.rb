class SurveysController < ApplicationController
  before_filter :authenticate_user!
  def index
    @surveys = Survey.all
  end
end
