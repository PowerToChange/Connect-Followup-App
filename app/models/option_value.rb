class OptionValue < CiviCrm::OptionValue
  def self.label_for(options)
    option_group_id = options[:option_group_id]
    option_group_id = CiviCrm::CustomField.find(options[:custom_field_id]).option_group_id unless option_group_id.present?

    option_value = CiviCrm::OptionValue.where(option_group_id: option_group_id).select do |ov|
      ov.value.to_s == options[:value].to_s
    end

    option_value.first.label
  rescue
    options[:value] || ''
  end
end