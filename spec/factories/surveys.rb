# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :survey do
    activity_type_id 32
    custom_group_id 9
    title "September Launch 2012"

    factory :survey_without_callbacks do
      after(:build) { |survey| survey.stub(:sync) }
      after(:build) { |survey| survey.stub(:fetch_custom_fields) }
    end
  end
end