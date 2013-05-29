class Survey < ActiveRecord::Base
  has_many :custom_fields
  has_many :survey_users
  has_many :users, :through => :survey_users

  attr_accessible :activity_type_id, :custom_group_id, :title

  validates_presence_of :activity_type_id

  before_validation :sync
  after_create :fetch_custom_fields

  def responses
    @responses ||= begin
      params = {
        activity_type_id: self.activity_type_id,
        'return.target_contact_id' => 1
      }
      self.custom_fields.each do |f|
        params["return.custom_#{f.custom_field_id}"] = 1
      end

      page = 28000 #28000 onwards to have contact details
      per_page = 100 #1000
      resp = []
      catch (:completed) do
        while 0 < 1 do
          CiviCrm::Activity.where(params.merge!({:rowCount => per_page, :offset => page})).each do |response|
            throw :completed if response.count.present?
            resp << Response.new(self, response) if response.target_contact_id.any?
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
    survey = CiviCrm::CustomGroup.where(:extends => 'Activity', :extends_entity_column_value => self.activity_type_id).first
    errors.add(:base, "Unable to find corresponding survey with activity type id #{self.activity_type_id} in Civicrm") if survey.count.present?
    self.custom_group_id = survey.id
    self.title = survey.title
  end

  def fetch_custom_fields
    CustomField.sync(self)
  end
end
