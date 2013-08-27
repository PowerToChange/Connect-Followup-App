# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :survey do
    survey_id 11
    activity_type_id ActivityType::PETITION_TYPE_ID
    campaign_id 8
    title "Power survey - July21-1"
    has_all_schools false

    factory :survey_without_callbacks do
      after(:build) { |survey| survey.stub(:sync) }
      after(:build) { |survey| survey.stub(:fetch_fields) }
      after(:build) { |survey| survey.stub(:update_responses_count_cache) }

      factory :survey_without_callbacks_with_schools do
        after(:build) { |survey| build(:school, surveys: [survey]) }
      end
    end
  end
end