# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Create admin user
AdminUser.create!(:email => 'admin@example.com', :password => 'password', :password_confirmation => 'password')

# Create one survey
Survey.where(activity_type_id: 32).first_or_create