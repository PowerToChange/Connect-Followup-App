# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
ConnectFollowup::Application.initialize!

# enable detailed CAS logging 
RAILS_ROOT = Rails.root.to_s unless defined? RAILS_ROOT

cas_logger = CASClient::Logger.new(RAILS_ROOT+'/log/cas.log')

cas_logger.level = Logger::DEBUG


CASClient::Frameworks::Rails::Filter.configure(
  :cas_base_url => "https://thekey.me/cas/",
  :login_url     => "https://thekey.me/cas/login", 
  :logout_url    => "https://thekey.me/cas/logout?service=http://p2c.com/students",
  :logger => cas_logger,
  :enable_single_sign_out => true
)

# Load the rails application

require File.expand_path('../application', __FILE__)

