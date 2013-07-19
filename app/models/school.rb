class School < ActiveRecord::Base
  attr_accessible :civicrm_id, :display_name, :pulse_id

  has_and_belongs_to_many :surveys
  has_and_belongs_to_many :users

  validates :civicrm_id, :pulse_id, :display_name, presence: true

  def to_s
    self.display_name
  end

  def civicrm_school
    @civicrm_school ||= CiviCrm::Contact.find(self.civicrm_id)
  end
end
