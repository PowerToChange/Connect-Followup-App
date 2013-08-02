class User < ActiveRecord::Base
  has_many :leads, dependent: :destroy
  has_and_belongs_to_many :schools
  has_many :surveys, through: :schools, uniq: true

  attr_accessible :email, :guid, :first_name, :last_name, :civicrm_id
  validates :email, format: { with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/ }, allow_blank: true
  validates :guid, presence: true

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
    surveys.map do |s|
      OpenStruct.new(
        survey: s,
        leads: self.leads.for_survey(s)
      )
    end
  end

  def sync_from_pulse
    pulse_campus_ids = []
    civicrm_id_from_pulse = nil
    Pulse::MinistryInvolvement.where(guid: self.guid).each do |ministry_involvement|
      civicrm_id_from_pulse ||= ministry_involvement.try(:user).try(:[], :civicrm_id)
      pulse_campus_ids += ministry_involvement.ministry[:campus].collect { |c| c[:campus_id] }
    end
    pulse_campus_ids.uniq!

  rescue Pulse::Errors::BadRequest # User does not exist in Pulse
    self.schools = []
  rescue # Unknown failure
    return false

  else
    self.schools = School.where(pulse_id: pulse_campus_ids)
    self.update_attribute(:civicrm_id, civicrm_id_from_pulse) if civicrm_id_from_pulse.present?
  end

end
