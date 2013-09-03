class ExportsController < ApplicationController
  before_filter :authenticate_user!, :get_survey

  def survey

  end

  private

  def get_survey
    @survey = Survey.find(params[:id])
  end
end
