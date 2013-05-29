class Lead < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey
  attr_accessible :response_id, :user_id

  scope :for_survey, lambda { |s| where(:survey_id => s.id) }
end
