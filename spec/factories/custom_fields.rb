# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :custom_field do
    survey
    custom_field_id 1
    label "Are you single and available?"
  end
end
