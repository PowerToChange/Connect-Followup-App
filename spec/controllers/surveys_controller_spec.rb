require 'spec_helper'

describe SurveysController, :vcr do
  login_user

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
