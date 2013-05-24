require 'spec_helper'

describe SurveysController do
  login_user
  describe "GET /surveys" do
    subject { get :index }
    it 'should return success', :vcr do
      subject
      response.should be_success
    end
    it 'assigns @surveys' do
      subject
      assigns(:surveys).should_not be_nil
    end
  end
end
