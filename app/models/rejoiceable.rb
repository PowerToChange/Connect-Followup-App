class Rejoiceable < Activity
  validates :custom_143, presence: true

  def initialize(attributes = {})
    attributes[:activity_type_id] = ActivityType::REJOICEABLE_TYPE_ID
    attributes[:status_id] = Lead::COMPLETED_STATUS_ID
    super(attributes)
  end
end