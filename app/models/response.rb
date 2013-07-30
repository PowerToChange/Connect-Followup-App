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
    survey.custom_fields.each do |f|
      params["return.custom_#{f.custom_field_id}"] = 1
    end
    CiviCrm::CustomValue.where(params).collect do |value|
      option_group_id = CiviCrm::CustomField.find(value.id).option_group_id
      value_label = CiviCrm::OptionValue.where(option_group_id: option_group_id, value: value.try(:latest)).first.label

      OpenStruct.new(:label => survey.custom_fields.find_by_custom_field_id(value.id).try(:label),
                     :answer => value_label)
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