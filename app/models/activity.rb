class Activity < CiviCrm::Activity
  validates :source_contact_id, :activity_type_id, :status_id, :target_contact_id, :details, presence: true
  validates CiviCrm.custom_fields.activity.rejoiceable.rejoiceable_id, presence: { :if => :is_rejoiceable? }
  validates CiviCrm.custom_fields.activity.rejoiceable.survey_id, presence: { :if => :is_rejoiceable? }

  STATUS_COMPLETED_ID = '2'

  def is_rejoiceable?
    self.activity_type_id == ActivityType::REJOICEABLE_TYPE_ID
  end
end