class School < ActiveRecord::Base
  attr_accessible :civicrm_id, :display_name, :pulse_id, :nick_name

  has_and_belongs_to_many :surveys
  has_and_belongs_to_many :users

  validates :civicrm_id, :pulse_id, :display_name, presence: true

  def self.all_civicrm_schools
    CiviCrm::Contact.where({ contact_type: 'Organization', contact_sub_type: 'School', rowCount: 10000 })
  end

  def self.sync_all_from_civicrm
    civicrm_schools = all_civicrm_schools

    # Create/update schools
    civicrm_schools.each do |ccs|
      school = School.where(civicrm_id: ccs.id).first_or_initialize
      school.update_attributes(display_name: ccs.display_name, pulse_id: ccs.external_identifier, nick_name: ccs.nick_name)
      school.save
    end

    # Remove schools that should no longer exist
    School.where("civicrm_id NOT IN (?)", civicrm_schools.collect(&:id)).each do |s|
      s.destroy
    end
  end

  def self.find_by_relationship(relationship)
    return nil unless relationship.present?
    civicrm_id = relationship.try(:contact_id_b).presence || relationship.try(:contact_id).presence
    self.where(civicrm_id: civicrm_id).first
  end

  def to_s
    self.display_name
  end

  def to_s_shorter
    self.nick_name.presence || self.display_name
  end

  def civicrm_school
    @civicrm_school ||= CiviCrm::Contact.find(self.civicrm_id)
  end

end
