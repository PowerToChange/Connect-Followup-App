class Activity < CiviCrm::Activity
  include CiviCrm::Ext

  validates_presence_of :source_contact_id, :activity_type_id, :activity_status_id, :target_contact_id

  STATUS_COMPLETED_ID = '2'
end