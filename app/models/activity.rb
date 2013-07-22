class Activity < CiviCrm::Activity
  validates :source_contact_id, :activity_type_id, :activity_status_id, :target_contact_id, :details, presence: true
  STATUS_COMPLETED_ID = '2'
end