# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
ConnectFollowup::Application.initialize!

def the_rails_root
  if defined? RAILS_ROOT
    RAILS_ROOT
  else
    Rails.root.to_s
  end
end

cas_logger = CASClient::Logger.new(the_rails_root+'/log/cas.log')
cas_logger.level = Logger::DEBUG

CASClient::Frameworks::Rails::Filter.configure(
  :cas_base_url => "https://thekey.me/cas/",
  :login_url => "https://thekey.me/cas/login",
  :logout_url => "https://thekey.me/cas/logout?service=http://p2c.com/students",
  :logger => cas_logger,
  :enable_single_sign_out => true
)