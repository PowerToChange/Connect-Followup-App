require 'spec_helper'

describe ConnectionsController do
  login_user

  describe "GET /connections", :vcr do
    let!(:survey) { create(:survey_without_callbacks) }
    let!(:survey_others) { create(:survey_without_callbacks) }
    let!(:lead_1) { create(:lead, survey_id: survey.id, user_id: user.id, response_id: '104254', contact_id: 60083) }
    let!(:lead_2) { create(:lead, survey_id: survey.id, user_id: user.id, response_id: '104252', contact_id: 60082) }

    before { user.stub(:surveys).and_return([survey]) }

    subject { get :index }
    it 'should return success' do
      subject
      response.should be_success
    end
    it 'assigns @connections' do
      subject
      assigns(:connections).should_not be_nil
    end
  end

end
