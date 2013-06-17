class Response
  attr_accessor :survey, :response

  def to_param
    response.id
  end

  def response_id
    response.id
  end

  def initialize(survey, response)
    @survey = survey
    @response = response
  end

  def answers
    @answers ||= begin
      survey.custom_fields.map do |field|
        OpenStruct.new(:label => field.label,
                       :answer => response.send("custom_#{ field.custom_field_id }"))
      end
    end
  end

  def contact
    @contact ||= CiviCrm::Contact.find(response.target_contact_id.try(:first))
  end

  def self.find(args)
    survey = args[:survey]
    id = args[:id]
    params = {
      activity_type_id: survey.activity_type_id,
      'return.target_contact_id' => 1,
      id: id
    }
    survey.custom_fields.each do |f|
      params["return.custom_#{f.custom_field_id}"] = 1
    end
    Response.new(survey, CiviCrm::Activity.where(params).first)
  end

end