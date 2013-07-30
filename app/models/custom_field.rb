class CustomField < ActiveRecord::Base
  belongs_to :survey
  attr_accessible :custom_field_id, :label

  class << self
    attr_accessor :survey
    def sync(survey)
      @survey = survey
      field_ids.each do |f|
        custom_field = CiviCrm::CustomField.find(f)
        field = survey.custom_fields.where(custom_field_id: custom_field.id).first_or_initialize(label: custom_field.label)
        if field.new_record?
          field.save
        else
          field.update_attribute(:label,custom_field.label)
        end
      end
    end

    private

    def field_ids
      survey_fields.collect(&:custom_field_id).reject(&:blank?)
    end

    def survey_fields
      CiviCrm::CustomSurveyFields.where(:survey_id => survey.survey_id, :rowCount => 1000)
    end
  end
end
