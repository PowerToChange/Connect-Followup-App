class Note < CiviCrm::Note
  validates :subject, :note, :entity_id, :contact_id, presence: true

  def initialize(*args)
    super(*args)
    work_around_bug_with_ids
  end

  def self.user_stamp(user)
    # This is a hack to provide some way of identifying notes to users due to CiviCrm limitations
    if user.to_s.present? && user.to_s != user.email
      "#{ user.to_s } (#{ user.email })"
    else
      "(#{ user.email })"
    end
  end

  private

  def work_around_bug_with_ids
    # We need to set both entity_id and contact_id the same in order for API chaining to work properly, this appears to be a bug in CiviCrm
    if self.contact_id.present?
      self.refresh_from({'entity_id' => self.contact_id})
    elsif self.entity_id.present?
      self.refresh_from({'contact_id' => self.entity_id})
    end
  end
end