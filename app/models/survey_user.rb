class SurveyUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey
  attr_accessible :user_id, :survey_id

  validates_uniqueness_of :survey_id, :scope => :user_id
end
