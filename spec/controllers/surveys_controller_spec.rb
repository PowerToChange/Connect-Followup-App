require 'spec_helper'

describe SurveysController, :vcr do
  login_user
  describe "GET /surveys" do
    let!(:survey) { create(:survey_without_callbacks) }
    let!(:survey_others) { create(:survey_without_callbacks) }
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
      assigns(:surveys).should =~ [survey, survey_others]
    end
  end

  describe "GET /surveys/:id" do
    let!(:survey) { create(:survey_without_callbacks) }
    subject { get :show, :id => survey.id }
    it { should be_success }
    it 'assigns @survey' do
      subject
      assigns(:survey).should == survey
    end
  end
end
