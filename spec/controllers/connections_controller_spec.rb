require 'spec_helper'

describe ConnectionsController do
  login_user

  describe "GET /connections" do
    let!(:survey) { create(:survey_without_callbacks) }
    let!(:survey_others) { create(:survey_without_callbacks) }

    subject { get :index }
    it 'should return success', :vcr do
      subject
      response.should be_success
    end
    it 'assigns @connections' do
      subject
      assigns(:connections).should_not be_nil
    end
  end

end
