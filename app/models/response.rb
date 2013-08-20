class Response
  attr_accessor :survey, :response, :school, :contact
  include ResponsesHelper

  def self.PRIORITIES
    [[I18n.t('responses.priorities.hot'), 1], [I18n.t('responses.priorities.medium'), 2], [I18n.t('responses.priorities.mild'), 3]]
  end

  def self.GENDERS
    [[I18n.t('responses.genders.female'), 1], [I18n.t('responses.genders.male'), 2]]
  end

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
    @answers ||= begin
      excluded_fields = [:first_name, :last_name, :gender_id, :email, :phone, CiviCrm.custom_fields.contact.year, CiviCrm.custom_fields.contact.international, CiviCrm.custom_fields.contact.degree]

      survey.fields.sort_by(&:label).collect do |field|
        next if excluded_fields.include?(field.field_name.to_sym)
        custom_values = [self.contact.send(field.field_name)].flatten # It may be an array or not, we always want an array
        value_label = custom_values.collect { |custom_value| field.label_for_option_value(custom_value) }.join(', ')
        OpenStruct.new(label: field.label, answer: value_label)
      end.compact
    end
  end

  def contact_infos
    @contact_infos ||= begin
      [
        OpenStruct.new(field: nil, label: I18n.t('responses.contact_info.school'), value: school.try(:display_name)),
        OpenStruct.new(field: :gender_id, label: I18n.t('responses.contact_info.gender'), value: gender_label(contact.gender_id)),
        OpenStruct.new(field: CiviCrm.custom_fields.contact.year, label: I18n.t('responses.contact_info.year'), value: year_label(contact.send(CiviCrm.custom_fields.contact.year))),
        OpenStruct.new(field: CiviCrm.custom_fields.contact.degree, label: I18n.t('responses.contact_info.degree'), value: contact.send(CiviCrm.custom_fields.contact.degree)),
        OpenStruct.new(field: CiviCrm.custom_fields.contact.international, label: I18n.t('responses.contact_info.international'), value: contact.send(CiviCrm.custom_fields.contact.international))
      ]
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