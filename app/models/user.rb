class User < ActiveRecord::Base
  has_many :leads, dependent: :destroy
  has_and_belongs_to_many :schools
  has_many :surveys, through: :schools, uniq: true

  attr_accessible :email, :guid, :first_name, :last_name
  validates :email, format: { with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/ }, allow_blank: true
  validates :guid, presence: true

  def to_s
    self.name || self.email || self.guid
  end

  def name
    [self.first_name, self.last_name].select(&:present?).join(' ')
  end

  def connections
    surveys.map do |s|
      OpenStruct.new(
        survey: s,
        leads: self.leads.for_survey(s)
      )
    end
  end

  def civicrm_contact_id
    '1' # Just use the CiviCrm admin's ID until this is properly supported
  end

  def sync_schools_from_pulse
    pulse_campus_ids = []
    Pulse::MinistryInvolvement.where(guid: self.guid).each do |ministry_involvement|
      pulse_campus_ids += ministry_involvement.ministry[:campus].collect { |c| c[:campus_id] }
    end
    pulse_campus_ids.uniq!

  rescue Pulse::Errors::BadRequest # User does not exist in Pulse
    self.schools = []
    return false
  rescue # Unknown failure
    return false

  else
    self.schools = School.where(pulse_id: pulse_campus_ids)
  end

end
