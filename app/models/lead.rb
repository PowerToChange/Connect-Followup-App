class Lead < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey
  attr_accessible :response_id, :survey_id, :status_id

  validates :response_id, :presence => true
  validates_uniqueness_of :response_id, :scope => :user_id

  scope :for_survey, lambda { |s| where(:survey_id => s.id) }

  PROGRESS_STATUSES = [[4, 'Uncontacted'] ,[3, 'WIP'],[2, 'Completed']]
end
