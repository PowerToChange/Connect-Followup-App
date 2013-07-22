class Note < CiviCrm::Note
  validates :subject, :note, :entity_id, :contact_id, presence: true
end