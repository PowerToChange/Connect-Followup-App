class Rejoiceable < Activity
  validates :custom_143, presence: true

  def initialize(attributes = {})
    self.activity_type_id = ActivityType::REJOICEABLE_TYPE_ID
    self.status_id = Lead::COMPLETED_STATUS_ID
    super(attributes)
  end
end