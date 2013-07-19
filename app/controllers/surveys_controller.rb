class SurveysController < ApplicationController
  before_filter :authenticate_user!
  def index
    @surveys = Survey.all
  end

  def show
    @survey = Survey.find(params[:id])
    @responses = @survey.responses(filters)
  end

  private

  def filters
    params[:filters].present? ? params[:filters] : {}
  end
end
