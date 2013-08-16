class Survey < ActiveRecord::Base
  has_many :fields, :dependent => :destroy
  has_many :leads, :dependent => :destroy
  has_and_belongs_to_many :schools
  has_many :users, :through => :schools, uniq: true

  attr_accessible :survey_id, :campaign_id, :activity_type_id, :title, :school_ids, :has_all_schools

  validates_presence_of :survey_id

  before_validation :sync
  after_save :fetch_fields, :associate_all_schools, :update_responses_count_cache

  def to_s
    self.title
  end

  def responses(options = {})
    @responses ||= begin
      params = responses_query_params.merge!(options)
      responses_query = PtcActivityQuery.where(params).includes(contacts: { contact_id: "$value.target_contact_id" })

      # We are anticipating this query to be called simultaneously by many people, cache it for a small period to ease the load
      Rails.cache.fetch(responses_query.url, expires_in: 2.minutes) do
        # Get all activities that match the params, and include their contacts, but only the contact with the matching target_contact_id
        responses = responses_query.all
        update_responses_count_cache(responses.size) if options.blank? # Update the survey responses count cache only if there are no filters in place
        responses.collect do |response|
          next if response.contacts.blank?
          Response.new(self, response, response.contacts.first)
        end
      end
    end
  end

  private

  def responses_query_params
    {
      campaign_id: self.campaign_id,
      activity_type_id: ActivityType::PETITION_TYPE_ID,
      source_record_id: self.survey_id,
      'return' => 'target_contact_id'
    }
  end

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

  def update_responses_count_cache(count = nil)
    count = PtcActivityQuery.where(responses_query_params).count if count.blank?
    self.update_column(:responses_count_cache, count) # update without invoking callbacks
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
