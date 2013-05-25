class Response
  attr_accessor :survey, :response
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
    @contact ||= CiviCrm::Contact.find(response.target_contact_id.first)
  end
end