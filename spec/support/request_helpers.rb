require 'spec_helper'
module RequestHelpers
  def login_user
    before do
      CASClient::Frameworks::Rails::Filter.fake("homer", {:role => "admin", :email => "homer@ballistiq.com"})
      ApplicationController.any_instance.stub(:current_user) { "homer" }
    end
  end
end