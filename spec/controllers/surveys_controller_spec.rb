require 'spec_helper'

describe SurveysController, :vcr do
  let!(:survey) { create(:survey_without_callbacks) }
  login_user

  describe "GET /surveys/:id" do
    subject { get :show, id: survey.id }

    it { should be_success }
    it 'assigns @survey' do
      subject
      assigns(:survey).should == survey
    end
    it 'assigns @responses' do
      subject
      assigns(:responses).should be_present
    end
  end

  describe "GET /surveys/:id/all" do
    subject { get :all, id: survey.id }

    it { should be_success }
    it 'assigns @survey' do
      subject
      assigns(:survey).should == survey
    end
    it 'assigns @responses' do
      subject
      assigns(:responses).should be_present
    end
  end
end
