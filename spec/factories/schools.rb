# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :school do
    civicrm_id 100
    pulse_id 200
    display_name "Xavier's School for Gifted Youngsters"
  end
end
