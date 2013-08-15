class User < ActiveRecord::Base
  has_many :leads, dependent: :destroy
  has_and_belongs_to_many :schools
  has_many :surveys, through: :schools, uniq: true

  attr_accessible :email, :guid, :first_name, :last_name, :civicrm_id
  validates :email, format: { with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/ }, allow_blank: true
  validates :guid, presence: true
  validates :civicrm_id, presence: true

  DEFAULT_CIVICRM_ID = 1

  def to_s
    if self.name.present?
      self.name
    elsif self.email.present?
      self.email
    else
      self.guid
    end
  end

  def name
    [self.first_name, self.last_name].select(&:present?).join(' ')
  end

  def connections
    leads_grouped_by_survey_id = Lead.find_and_preset_all_by_leads(self.leads).group_by(&:survey_id)

    surveys.map do |survey|
      OpenStruct.new(
        survey: survey,
        leads: leads_grouped_by_survey_id[survey.id] || []
      )
    end
  end

  def sync_from_pulse
    pulse_campus_ids = []
    civicrm_id_from_pulse = nil

    Pulse::MinistryInvolvement.where(guid: self.guid).each do |ministry_involvement|
      # Get the CiviCrm id of the user from the Pulse
      civicrm_id_from_pulse ||= ministry_involvement.try(:user).try(:[], :civicrm_id)

      # Collect the school ids that this user is associated to
      #   ministry_involvement.ministry[:campus] will be an array only if there are multiple campuses
      pulse_campus_ids += [ministry_involvement.ministry[:campus]].flatten.collect { |c| c[:campus_id] }
    end
    pulse_campus_ids.uniq!

  rescue Pulse::Errors::BadRequest
    Rails.logger.error "Pulse::Errors::BadRequest: User does not exist in the Pulse! #{self.inspect}"
    self.schools = [] # Unassign all of the user's schools, they may have been intentionally removed from the Pulse

  rescue => e # Unknown failure
    Rails.logger.error "Failed to sync user from Pulse: #{e} #{self.inspect}"
    return false

  else
    self.schools = School.where(pulse_id: pulse_campus_ids)
    self.update_attribute(:civicrm_id, civicrm_id_from_pulse) if civicrm_id_from_pulse.present?
  end

end
