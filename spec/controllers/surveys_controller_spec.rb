require 'spec_helper'

describe SurveysController do
  login_user
  describe "GET /surveys" do
    let!(:survey) { create(:survey_without_callbacks) }
    let!(:survey_others) { create(:survey_without_callbacks) }
    let!(:survey_user) { create(:survey_user, :survey_id => survey.id, :user_id => user.id) }
    subject { get :index }
    it 'should return success', :vcr do
      subject
      response.should be_success
    end
    it 'assigns @surveys' do
      subject
      assigns(:surveys).should_not be_nil
    end
    it 'assigns only surveys belonging to user' do
      subject
      assigns(:surveys).should =~ [survey]
    end
  end
end
