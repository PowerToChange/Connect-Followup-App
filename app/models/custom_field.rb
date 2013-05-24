class CustomField < ActiveRecord::Base
  belongs_to :survey
  attr_accessible :custom_field_id, :label
end
