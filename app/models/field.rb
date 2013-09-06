class Field < ActiveRecord::Base
  belongs_to :survey
  attr_accessible :field, :label, :option_group_id

  validates_presence_of :field_name, :survey_id

  scope :with_option_group, -> { where('option_group_id IS NOT NULL') }
  scope :answers, -> { all.reject { |field| Field::CONTACT_INFO_FIELD_NAMES.include?(field.field_name.to_sym) } }
  scope :contact_infos, -> { all.select { |field| Field::CONTACT_INFO_FIELD_NAMES.include?(field.field_name.to_sym) } }

  CONTACT_INFO_FIELD_NAMES = [
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

  def option_values
    @option_values ||= CiviCrm::OptionValue.where(option_group_id: self.option_group_id, rowCount: 1000)
  end

  def label_for_option_value(value)
    Rails.cache.fetch([self.inspect, value], expires_in: 1.day) do
      option_values.detect { |ov| ov.value == value }.try(:label) || value
    end
  end

  def option_values_to_select_options
    option_values.sort_by(&:label).collect { |ov| [ov.label, ov.value] }
  end

  class << self
    attr_accessor :survey

    def sync(survey)
      @survey = survey

      survey_fields.each do |survey_field|
        if survey_field.custom_field_id.present?
          custom_field = CiviCrm::CustomField.find(survey_field.custom_field_id)
          label = custom_field.label
        else
          label = survey_field.field_name.humanize
        end
        field = survey.fields.where(field_name: survey_field.field_name, custom_field_id: survey_field.custom_field_id).first_or_initialize
        field.update_attributes(label: label, option_group_id: custom_field.try(:option_group_id))
      end
    end

    private

    def survey_fields
      CiviCrm::CustomSurveyFields.where(survey_id: @survey.survey_id, campaign_id: @survey.campaign_id, activity_type_id: ActivityType::PETITION_TYPE_ID).all
    end
  end
end
