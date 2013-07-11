class Survey < ActiveRecord::Base
  has_many :custom_fields
  has_many :survey_users
  has_many :users, :through => :survey_users
  has_many :leads

  attr_accessible :survey_id, :campaign_id, :activity_type_id, :title

  validates_presence_of :survey_id

  before_validation :sync
  after_create :fetch_custom_fields

  def responses
    @responses ||= begin
      params = {
        campaign_id: self.campaign_id,
        source_record_id: self.survey_id,
        'return' => 'target_contact_id'
      }

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
end
