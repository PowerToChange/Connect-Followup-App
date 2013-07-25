class Survey < ActiveRecord::Base
  has_many :custom_fields, :dependent => :destroy
  has_many :leads, :dependent => :destroy
  has_and_belongs_to_many :schools
  has_many :users, :through => :schools, uniq: true

  attr_accessible :survey_id, :campaign_id, :activity_type_id, :title, :school_ids, :has_all_schools

  validates_presence_of :survey_id

  before_validation :sync
  after_create :fetch_custom_fields
  after_save :associate_all_schools

  def to_s
    self.title
  end

  def responses(options = {})
    @responses ||= begin
      params = {
        campaign_id: self.campaign_id,
        source_record_id: self.survey_id,
        'return' => 'target_contact_id'
      }.merge!(options)

      page = 0
      per_page = 100
      resp = []
      catch (:completed) do
        while 0 < 1 do
          CiviCrm::Activity.where(params.merge!({:rowCount => per_page, :offset => page})).each do |response|
            throw :completed if response.count.present?
            resp << Response.new(self, response) if response.target_contact_id.try(:any?)
          end
          page += per_page
          puts ">>> Fetching records... #{page}"
        end
      end
      resp
    end
  end

  private

  def sync
    survey = CiviCrm::Survey.where(:id => self.survey_id).first
    if survey.count.present?
      errors.add(:base, "Unable to find corresponding survey with id #{self.survey_id} in Civicrm")
    else
      self.campaign_id = survey.campaign_id
      self.activity_type_id = survey.activity_type_id
      self.title = survey.title
    end
  end

  def fetch_custom_fields
    CustomField.sync(self)
  end

  def associate_all_schools
    if self.has_all_schools_changed? || self.id_changed?
      self.schools = self.has_all_schools? ? School.all : []
    end
  end

  # When a school is created associate it to surveys that have all schools
  School.class_eval do
    after_create do |school|
      Survey.where(has_all_schools: true).each do |survey|
        survey.schools << school
      end
    end
  end

end
