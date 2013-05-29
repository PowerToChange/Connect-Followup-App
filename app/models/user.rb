class User < ActiveRecord::Base
  has_many :survey_users
  has_many :surveys, :through => :survey_users

  attr_accessible :email
  validates :email, :presence => true, :format => { :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/ }

  def to_s
    self.email
  end
end
