# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :survey do
    survey_id 2
    activity_type_id 32
    campaign_id 2
    title "Sept 2012 petition"

    factory :survey_without_callbacks do
      after(:build) { |survey| survey.stub(:sync) }
      after(:build) { |survey| survey.stub(:fetch_custom_fields) }
    end
  end
end