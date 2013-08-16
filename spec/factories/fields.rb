# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :field do
    survey_id 1
    custom_field_id 1
    label "Are you single and available?"
    option_group_id 2
    field_name "availability"
  end
end
