require 'spec_helper'
module RequestHelpers
  def login_user
    let!(:user) { create(:user) }
    before do
      CASClient::Frameworks::Rails::Filter.fake("homer", {:role => "admin", :email => "homer@ballistiq.com"})
      ApplicationController.any_instance.stub(:current_user) { user }
    end
  end
end