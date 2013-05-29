# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :survey_user do
    user
    survey
  end
end
