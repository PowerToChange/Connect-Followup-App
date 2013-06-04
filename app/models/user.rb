class User < ActiveRecord::Base
  has_many :survey_users, :dependent => :destroy
  has_many :surveys, :through => :survey_users
  has_many :leads

  attr_accessible :email
  validates :email, :presence => true, :format => { :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/ }

  def to_s
    self.email
  end

  def connections
    surveys.map do |s|
      OpenStruct.new(
        survey: s,
        leads: self.leads.for_survey(s).map {|l| Response.find(survey: s, id: l.response_id) }
      )
    end
  end
end
