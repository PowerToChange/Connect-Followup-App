class Lead < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey
  attr_accessible :response_id, :survey_id, :status_id, :engagement_level, :contact_id
  attr_accessor :response, :contact

  validates :response_id, :contact_id, presence: true
  validates_uniqueness_of :response_id, scope: :user_id

  scope :for_survey, ->(s) { where(survey_id: s.id) }

  COMPLETED_STATUS_ID = 2
  WIP_STATUS_ID = 3
  UNCONTACTED_STATUS_ID = 4
  PROGRESS_STATUSES = [[UNCONTACTED_STATUS_ID, 'Uncontacted'], [WIP_STATUS_ID, 'In Progress'], [COMPLETED_STATUS_ID, 'Completed']]

  REPORT_CODES = OpenStruct.new(bad_info: 0,
                                no_response: 1,
                                not_interested: 2,
                                digital: 5,
                                face: 7,
                                digital_cont: 8,
                                face_cont: 10)

  before_save :update_status_engagement_level_to_civicrm, if: :persisted?

  def status
    PROGRESS_STATUSES.select { |num|  num[0] == self.status_id  }.flatten[1]
  end

  def response
    @response ||= Response.find(survey: survey, id: response_id)
  end

  def contact
    @contact ||= self.response.contact
  end

  def self.find_by_contact_with_activities(contact)
    # The contact has many activities, we don't know which one exactly is the one we want yet
    activity_ids = contact.activities.select { |a| a.activity_type_id.to_i == Survey::PETITION_ACTIVITY_TYPE_ID.to_i }.collect(&:id)

    # Find the lead related to this contact
    lead = Lead.where(contact_id: contact.id, response_id: activity_ids).first

    # Pre-set the lead's contact
    lead.contact = contact

    # Use the activity from the lead that we found earlier
    activity = contact.activities.detect { |a| a.id.to_i == lead.response_id.to_i }

    # Initialize the response and pre-set it on the lead
    lead.response = Response.new(lead.survey, activity)

    lead
  end

  private

  def update_status_engagement_level_to_civicrm
    a = CiviCrm::Activity.find(self.response_id)
    a.status_id = self.status_id
    if self.engagement_level
      a.refresh_from({'engagement_level' => self.engagement_level})
    end
    a.save
  end

end
