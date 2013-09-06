class User < ActiveRecord::Base
  has_many :leads, dependent: :destroy
  has_and_belongs_to_many :schools
  has_many :surveys, through: :schools, uniq: true

  attr_accessible :email, :guid, :first_name, :last_name, :civicrm_id
  validates :email, format: { with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/ }, allow_blank: true
  validates :guid, presence: true

  DEFAULT_CIVICRM_ID = 1
  VALID_PULSE_MINISTRY_INVOLVEMENT_ROLES = ["student leader", "ministry leader", "team member", "team leader"]

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

  def connections(options = {})
    # Cache based on the user's surveys, leads and filter options
    Rails.cache.fetch(connections_cache_key(options)) do

      @activities = self.leads.present? ? PtcActivityQuery.where(id: self.leads.collect(&:response_id).join(',')).where(options).where(PtcActivityQuery.params_to_return_school).all(1000) : []

      # Group all activities by their survey
      activities_grouped_by_source_record_id = @activities.group_by(&:source_record_id)

      self.surveys.collect do |survey|
        # Build the responses
        responses = (activities_grouped_by_source_record_id[survey.survey_id.to_s].presence || []).collect { |activity| Response.new(survey, activity) }
        responses.try(:sort_by!) { |r| r.contact.try(:display_name).try(:downcase) }
        OpenStruct.new(
          survey: survey,
          responses: responses.presence || []
        )
      end

    end
  end

  def sync_from_pulse
    pulse_campus_ids = []
    civicrm_id_from_pulse = nil

    Pulse::MinistryInvolvement.where(guid: self.guid).select { |mi| valid_pulse_ministry_involvement?(mi) }.each do |ministry_involvement|
      # Get the CiviCrm id of the user from the Pulse
      civicrm_id_from_pulse ||= ministry_involvement.try(:user).try(:[], :civicrm_id)

      # Collect the school ids that this user is associated to
      #   ministry_involvement.ministry[:campus] will be an array only if there are multiple campuses
      pulse_campus_ids += [ministry_involvement.ministry[:campus]].flatten.collect { |c| c[:campus_id] }
    end
    pulse_campus_ids.uniq!

  rescue Pulse::Errors::BadRequest
    Rails.logger.error "Pulse::Errors::BadRequest: User does not exist in the Pulse! #{self.inspect}"
    # This user may have been intentionally removed from the Pulse
    self.schools = []
    self.update_attribute(:civicrm_id, nil)

  rescue => e # Unknown failure
    Rails.logger.error "Failed to sync user from Pulse: #{e} #{self.inspect}"
    return false

  else
    self.schools = School.where(pulse_id: pulse_campus_ids)
    self.update_attribute(:civicrm_id, civicrm_id_from_pulse) if civicrm_id_from_pulse.present?
  end

  def valid_pulse_ministry_involvement?(ministry_involvement)
    VALID_PULSE_MINISTRY_INVOLVEMENT_ROLES.include?(ministry_involvement.try(:role).try(:[], :name).try(:downcase))
  end

  private

  def connections_cache_key(options = {})
    ['user:', self, 'leads:', self.leads, 'surveys:', self.surveys, 'options:', options]
  end

end
