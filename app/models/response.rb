class Response
  attr_accessor :survey, :response

  PRIORITIES = [['Hot',1], ['Medium',2], ['Mild',3]]
  GENDERS = [['Female',1], ['Male',2]]
  YEARS = [['First Year', 1]]

  def initialize(survey, response)
    @survey = survey
    @response = response
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

  def answers
    params = {
      entity_id: response_id,
      rowCount: 1000
    }
    survey.custom_fields.each { |f| params["return.custom_#{ f.custom_field_id }"] = 1 }

    CiviCrm::CustomValue.where(params).collect do |custom_value|
      custom_field = survey.custom_fields.find_by_custom_field_id(custom_value.id)
      value_label = custom_field.label_for_option_value(custom_value.try(:latest))

      OpenStruct.new(label: custom_field.try(:label), answer: value_label)
    end
  end

  def contact
    @contact ||= Contact.find(contact_id)
  end

  def contact_id
    response.target_contact_id.is_a?(Array) ? response.target_contact_id.try(:first) : response.target_contact_id
  end

  def source_contact
    @source_contact ||= Contact.find(response.source_contact_id.try(:first))
  end

  def school
    @school ||= begin
      school_id = Relationship.where(contact_id_a: contact_id, relationship_type_id: Relationship::SCHOOL_CURRENTLY_ATTENDING_TYPE_ID).first.try(:contact_id_b)
      School.where(civicrm_id: school_id).first
    end
  end

  def self.find(args)
    survey = args[:survey]
    id = args[:id]

    params = {
      'return' => 'target_contact_id',
      id: id
    }
    Response.new(survey, CiviCrm::Activity.where(params).first)
  end

end