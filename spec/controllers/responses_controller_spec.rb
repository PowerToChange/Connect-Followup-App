require 'spec_helper'

describe ResponsesController do
  login_user

  let(:lead) { create(:lead, contact_id: 60058, response_id: 104210, user: user) }
  let(:survey) { lead.survey }

  describe 'show' do
    subject { get :show, survey_id: lead.survey_id, contact_id: lead.contact_id, id: lead.response_id }

    it 'should return success', :vcr do
      subject
      response.should be_success
    end

    it 'initializes contact in the response', :vcr do
      subject
      assigns(:response).contact.should_not be_nil
      assigns(:response).contact_id.to_i.should eq lead.contact_id.to_i
    end

    it 'assigns @response', :vcr do
      subject
      assigns(:response).should_not be_nil
      assigns(:response).id.to_i.should eq lead.response_id.to_i
      assigns(:response).survey.id.to_i.should eq lead.survey_id.to_i
    end

    it 'assigns @activities', :vcr do
      subject
      assigns(:activities).should_not be_nil
    end

    it 'assigns @notes', :vcr do
      subject
      assigns(:notes).should_not be_nil
    end

    it 'assigns @rejoiceables_collection', :vcr do
      subject
      assigns(:rejoiceables_collection).should_not be_nil
    end
  end
end
