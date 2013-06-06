# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lead do
    user
    survey
    response_id "55412"
    status_id 4
  end
end
