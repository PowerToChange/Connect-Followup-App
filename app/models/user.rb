class User < ActiveRecord::Base
  has_many :survey_users, :dependent => :destroy
  has_many :surveys, :through => :survey_users
  has_many :leads, :dependent => :destroy
  has_and_belongs_to_many :schools

  attr_accessible :email
  validates :email, :presence => true, :format => { :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/ }

  def to_s
    self.email
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
end
