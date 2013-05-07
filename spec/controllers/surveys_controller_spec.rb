require 'spec_helper'

describe SurveysController do
  login_user
  describe "GET /surveys" do
    subject { get :index }
    it 'should return success', :vcr do
      subject
      response.should be_success
    end
    it 'should request surveys from Civicrm', :vcr do
      CiviCrm::Activity.should_receive(:find)
      subject
    end
  end
end
