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

  def self.find_and_preset_all_by_leads(leads)
    # We want to fetch and build the leads with their associated CiviCrm data by only making one call total to CiviCrm

    # Make the call to CiviCrm
    contacts = Contact.includes(:activities).where(id: leads.collect(&:contact_id)).all

    # Setup each lead's data from the CiviCrm response
    leads.collect do |lead|
      # Find and set the lead's contact
      contact = contacts.detect { |c| c.id.to_i == lead.contact_id.to_i }
      lead.contact = contact

      # The contact has many activities, use the lead we received to find the exact activity we want
      activity = contact.activities.select { |a| a.id.to_i == lead.response_id.to_i }

      # Initialize and set the response
      lead.response = Response.initialize_and_preset_by_survey_and_contact_and_activity(lead.survey, contact, activity)

      lead
    end
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
