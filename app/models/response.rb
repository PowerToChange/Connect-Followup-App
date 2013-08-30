class Response
  attr_accessor :survey, :response, :school, :contact
  include ResponsesHelper

  CONTACT_INFO_FIELDS = [
    :first_name,
    :last_name,
    :gender_id,
    :email,
    :phone,
    CiviCrm.custom_fields.contact.year,
    CiviCrm.custom_fields.contact.year_other,
    CiviCrm.custom_fields.contact.international,
    CiviCrm.custom_fields.contact.degree,
    CiviCrm.custom_fields.contact.residence
  ]

  def self.PRIORITIES
    [[I18n.t('responses.priorities.hot'), 1], [I18n.t('responses.priorities.medium'), 2], [I18n.t('responses.priorities.mild'), 3], [I18n.t('responses.priorities.not_interested'), 4], [I18n.t('responses.priorities.not_applicable'), 5]]
  end

  def self.GENDERS
    [[I18n.t('responses.genders.female'), 1], [I18n.t('responses.genders.male'), 2]]
  end

  def initialize(survey, activity, contact =  nil, school = nil)
    @survey = survey
    @response = activity
    @contact = contact.presence || @response.try(:contacts).try(:first)
    @school = school.presence || School.find_by_relationship(@contact.try(:relationships).try(:last))
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
    @answers ||= begin

      survey.fields.sort_by(&:label).collect do |field|
        next if CONTACT_INFO_FIELDS.include?(field.field_name.to_sym)

        custom_values = self.response.send(field.field_name).presence || self.contact.send(field.field_name)
        custom_values = [custom_values].flatten # It may or may not be an array, we always want an array
        value_label = custom_values.collect { |custom_value| field.label_for_option_value(custom_value) }.join('; ')
        OpenStruct.new(label: field.label, answer: value_label)

      end.compact

    end
  end

  def contact_infos
    @contact_infos ||= begin

      [ OpenStruct.new(field: nil, label: I18n.t('responses.contact_info.school'), value: school.try(:display_name)) ] +

      CONTACT_INFO_FIELDS.reject { |f| [:email, :phone, :first_name, :last_name].include?(f) }.collect do |field|
        OpenStruct.new(field: field, label: Field.where(field_name: field).first.try(:label), value: answer_label(field, contact.send(field)))
      end.compact

    end
  end

  def contact_id
    @contact_id ||= begin
      if @contact.present?
        @contact.id.presence || @contact.contact_id
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
      # In this case activity is an ID, not an instance of Activity
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