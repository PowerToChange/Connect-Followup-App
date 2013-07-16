class Lead < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey
  attr_accessible :response_id, :survey_id, :status_id

  validates :response_id, :presence => true
  validates_uniqueness_of :response_id, :scope => :user_id

  scope :for_survey, lambda { |s| where(:survey_id => s.id) }

  COMPLETED_STATUS_ID = 2
  WIP_STATUS_ID = 3
  UNCONTACTED_STATUS_ID = 4
  PROGRESS_STATUSES = [[UNCONTACTED_STATUS_ID, 'Uncontacted'], [WIP_STATUS_ID, 'WIP'], [COMPLETED_STATUS_ID, 'Completed']]

  def status
    PROGRESS_STATUSES.select { |num|  num[0] == self.status_id  }.flatten[1]
  end

  def response
    Response.find(survey: survey, id: response_id)
  end

  delegate :contact, :to => :response
end
