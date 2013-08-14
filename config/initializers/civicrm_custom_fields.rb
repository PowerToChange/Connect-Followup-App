module CiviCrm
  require 'ostruct'
  mattr_accessor :custom_fields
end

CiviCrm.custom_fields = case Rails.env.production?
when true
  OpenStruct.new(
    activity: OpenStruct.new(rejoiceable: OpenStruct.new(rejoiceable_id: :custom_143, survey_id: :custom_152))
  )
else
  OpenStruct.new(
    activity: OpenStruct.new(rejoiceable: OpenStruct.new(rejoiceable_id: :custom_143, survey_id: :custom_160))
  )
end