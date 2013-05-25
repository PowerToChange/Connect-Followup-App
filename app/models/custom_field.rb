class CustomField < ActiveRecord::Base
  belongs_to :survey
  attr_accessible :custom_field_id, :label

  class << self
    def sync(survey)
      fields = CiviCrm::CustomField.where(:custom_group_id => survey.custom_group_id, :rowCount => 1000)
      fields.each do |f|
        field = survey.custom_fields.where(custom_field_id: f.id).first_or_initialize(label: f.label)
        if field.new_record?
          field.save
        else
          field.update_attribute(:label,f.label)
        end
      end
    end
  end
end
