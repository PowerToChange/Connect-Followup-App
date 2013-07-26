class Activity < CiviCrm::Activity
  validates :source_contact_id, :activity_type_id, :status_id, :target_contact_id, :details, presence: true
  validates :custom_143, presence: { :if => :is_rejoiceable? }
  STATUS_COMPLETED_ID = '2'

  private

  def is_rejoiceable?
    self.activity_type_id == ActivityType::REJOICEABLE_TYPE_ID
  end
end