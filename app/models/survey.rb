class Survey < ActiveRecord::Base
  has_many :fields, :dependent => :destroy
  has_many :leads, :dependent => :destroy
  has_and_belongs_to_many :schools
  has_many :users, :through => :schools, uniq: true

  attr_accessible :survey_id, :campaign_id, :activity_type_id, :title, :school_ids, :has_all_schools

  validates_presence_of :survey_id

  before_validation :sync
  after_save :fetch_fields, :associate_all_schools

  def to_s
    self.title
  end

  def responses(options = {})
    responses_query = PtcActivityQuery.where_survey(options, self)
    responses_query.where(PtcActivityQuery.params_to_return_school) unless options.delete(:exclude_nested_school) == true # allow this for performance reasons

    # We are anticipating this query to be called simultaneously by many people, cache it for a small period to ease the load
    Rails.cache.fetch(responses_query.url, expires_in: 1.minute) do

      responses = responses_query.all
      responses.collect { |response| Response.new(self, response) } # Build the responses

    end
  end

  def all_of_the_responses!(options = {})
    time_start = Time.now
    responses = []
    page_of_responses = []
    offset = 0
    page_size = 500

    begin
      page_of_responses = self.responses(options.merge(offset: offset, 'rowCount' => page_size))
      responses += page_of_responses
      offset += page_size
    end until page_of_responses.length < page_size

    Rails.logger.debug("all_of_the_responses! in #{ (Time.now - time_start) * 1000.0 }ms for #{ responses.size } responses")

    responses
  end

  def fields_to_return_from_civicrm
    extra_fields = [
      :display_name,
      CiviCrm.custom_fields.activity.rejoiceable.rejoiceable_id,
      CiviCrm.custom_fields.activity.rejoiceable.survey_id,
      CiviCrm.custom_fields.contact.year,
      CiviCrm.custom_fields.contact.degree,
      CiviCrm.custom_fields.contact.international
    ]
    (self.fields.collect(&:field_name) + extra_fields).join(',')
  end

  private


  def sync
    survey = CiviCrm::Survey.where(:id => self.survey_id).first

    if survey.present?
      self.campaign_id = survey.campaign_id
      self.activity_type_id = survey.activity_type_id
      self.title = survey.title
    else
      errors.add(:base, "Unable to find corresponding survey with id #{self.survey_id} in Civicrm")
    end
  end

  def fetch_fields
    Field.sync(self)
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
