module CiviCrm
  require 'ostruct'
  mattr_accessor :custom_fields
end

CiviCrm.custom_fields = case Rails.env.production?
when true
  OpenStruct.new(
    contact: OpenStruct.new(year: :custom_57, degree: :custom_59, international: :custom_61),
    activity: OpenStruct.new(rejoiceable: OpenStruct.new(rejoiceable_id: :custom_143, survey_id: :custom_152))
  )
else
  OpenStruct.new(
    contact: OpenStruct.new(year: :custom_57, degree: :custom_59, international: :custom_61),
    activity: OpenStruct.new(rejoiceable: OpenStruct.new(rejoiceable_id: :custom_143, survey_id: :custom_160))
  )
end