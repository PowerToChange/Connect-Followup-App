class Lead < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey
  belongs_to :school
  attr_accessible :response_id, :survey_id, :status_id, :engagement_level, :contact_id, :user_id
  attr_accessor :response, :contact

  validates :response_id, :contact_id, :user_id, :survey_id, presence: true
  validates_uniqueness_of :response_id

  scope :for_survey, ->(s) { where(survey_id: s.id) }

  before_save :update_status_engagement_level_to_civicrm, :create_contact_completed_note_history, if: :persisted?
  before_create :update_activity_assigned_user_on_civicrm
  after_destroy :update_activity_assigned_user_on_civicrm

  COMPLETED_STATUS_ID = 2
  WIP_STATUS_ID = 3
  UNCONTACTED_STATUS_ID = 4
  PROGRESS_STATUSES = [[UNCONTACTED_STATUS_ID, 'Uncontacted'], [WIP_STATUS_ID, 'In Progress'], [COMPLETED_STATUS_ID, 'Completed']]

  REPORT_OUTCOMES = {
    bad_info: { id: 0, description: 'bad information' },
    no_response: { id: 1, description: 'no response' },
    not_interested: { id: 2, description: 'not interested' },
    digitally: { id: 5, description: 'connected digitally' },
    face_to_face: { id: 7, description: 'connected face-to-face' },
    digitally_continuing: { id: 8, description: 'connected digitally and will continue the conversation' },
    face_to_face_continuing: { id: 10, description: 'connected face-to-face and will continue the conversation' }
  }
  REPORT_OUTCOMES_GROUPED_BY_ID = Hash[ REPORT_OUTCOMES.collect { |k,v| [REPORT_OUTCOMES[k][:id], v] } ]


  def status
    PROGRESS_STATUSES.select { |num|  num[0] == self.status_id  }.flatten[1]
  end

  def response
    @response ||= Response.find(survey: survey, id: response_id)
  end

  def contact
    @contact ||= self.response.contact
  end

  def uncontacted?
    status_id == UNCONTACTED_STATUS_ID
  end

  def uncontacted
    self.status_id = UNCONTACTED_STATUS_ID
    self
  end

  def completed?
    status_id == COMPLETED_STATUS_ID
  end

  def completed
    self.status_id = COMPLETED_STATUS_ID
    self
  end

  def in_progress?
    status_id == WIP_STATUS_ID
  end

  def in_progress
    self.status_id = WIP_STATUS_ID
    self
  end

  def self.find_and_preset_all_by_leads(leads)
    return [] if leads.blank?

    # We want to fetch and build the leads with their associated CiviCrm data by only making one call total to CiviCrm

    # Make the call to CiviCrm
    contacts = Contact.includes(:activities, relationships: { relationship_type_id: Relationship::SCHOOL_CURRENTLY_ATTENDING_TYPE_ID }).where(id: leads.collect(&:contact_id)).all

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
    update_params = { id: self.response_id, status_id: self.status_id }
    update_params[:engagement_level] = self.engagement_level if self.engagement_level.present?
    CiviCrm::Activity.update(update_params)
  end

  def update_activity_assigned_user_on_civicrm
    # Assign/Unassign the user to the lead in CiviCrm
    contact_id = self.destroyed? ? User::DEFAULT_CIVICRM_ID : self.user.civicrm_id
    CiviCrm::Activity.update({ id: self.response_id, assignee_contact_id: contact_id })
  end

  def create_contact_completed_note_history
    if self.engagement_level.present? && self.engagement_level_changed? && self.completed?
      Note.create(subject: 'Completed Initial Follow-up',
                  note: generate_contact_completed_note_body(self.user, self.survey, self.engagement_level),
                  contact_id: self.contact_id)
    end
  end

  def generate_contact_completed_note_body(user, survey, engagement_level)
    "#{ user.to_s } completed initial follow-up of the #{ survey.to_s } survey and recorded a result of #{ REPORT_OUTCOMES_GROUPED_BY_ID[engagement_level.to_i][:description] }."
  end
end
