class CustomField < ActiveRecord::Base
  belongs_to :survey
  attr_accessible :custom_field_id, :label, :option_group_id

  def option_values
    @option_values ||= CiviCrm::OptionValue.where(option_group_id: self.option_group_id, rowCount: 1000)
  end

  def label_for_option_value(value)
    option_values.select { |ov| ov.value == value }.first.try(:label) || value
  end

  class << self
    attr_accessor :survey

    def sync(survey)
      @survey = survey

      field_ids.each do |f|
        custom_field = CiviCrm::CustomField.find(f)
        field = survey.custom_fields.where(custom_field_id: custom_field.id).first_or_initialize
        field.update_attributes(label: custom_field.label, option_group_id: custom_field.option_group_id)
      end
    end

    private

    def field_ids
      survey_fields.collect(&:custom_field_id).reject(&:blank?)
    end

    def survey_fields
      CiviCrm::CustomSurveyFields.where(survey_id: survey.survey_id, campaign_id: survey.campaign_id, activity_type_id: ActivityType::PETITION_TYPE_ID).all
    end
  end
end
