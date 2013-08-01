# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email "adrian@ballistiq.com"
    guid "imgloballyunique"
    civicrm_id 2394823
  end
end
