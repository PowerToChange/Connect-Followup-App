class Response
  attr_accessor :survey, :response, :school, :contact

  PRIORITIES = [['Hot',1], ['Medium',2], ['Mild',3]]
  GENDERS = [['Female',1], ['Male',2]]
  YEARS = [['First Year', 1]]

  def initialize(survey, response, contact, school = nil)
    @survey = survey
    @response = response
    @contact = contact
    @school = school
  end

  def to_param
    response.id
  end

  def survey_id
    survey.id
  end

  def response_id
    response.id
  end
  alias_method :id, :response_id

  def answers
    survey.custom_fields.collect do |custom_field|
      custom_value = self.contact.attributes["custom_#{ custom_field.custom_field_id }"]
      value_label = custom_field.label_for_option_value(custom_value)
      OpenStruct.new(label: custom_field.label, answer: value_label)
    end
  end

  def contact_id
    @contact_id ||= begin
      if @contact.present?
        @contact.id
      else
        response.target_contact_id.is_a?(Array) ? response.target_contact_id.try(:first) : response.target_contact_id
      end
    end
  end

  def lead
    @lead ||= Lead.where(response_id: response_id).first
  end

  def self.find(args)
    survey = args[:survey]
    id = args[:id]

    params = {
      'return' => 'target_contact_id',
      id: id
    }
    activity = CiviCrm::Activity.where(params).includes(contacts: { contact_id: "$value.target_contact_id" }).first
    contact = activity.contacts.first
    Response.new(survey, activity, contact)
  end

  def self.initialize_and_preset_by_survey_and_contact_and_activity(survey, contact, activity)
    if activity.respond_to?(:to_i) && activity.to_i.present?
      # activity is an ID not an instance of Activity
      # The contact has many activities, find the relevant activity from the ID
      activity = contact.activities.detect { |a| a.id.to_i == activity.to_i }
    end

    # Initialize the school if we can
    if contact.relationships.present?
      school_relationship = contact.relationships.detect { |r| r.relationship_type_id.to_i == Relationship::SCHOOL_CURRENTLY_ATTENDING_TYPE_ID.to_i }
      school = school_relationship.present? ? School.find_by_relationship(school_relationship) : nil
    end

    # Initialize the response
    Response.new(survey, activity, contact, school)
  end

end