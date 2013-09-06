require 'spec_helper'

describe ExportsController do
  login_user

  describe 'survey', :vcr do
    let!(:survey) { create(:survey_without_callbacks) }
    subject { get :survey, id: survey.id }

    it 'should return success' do
      subject
      response.should be_success
    end
    it 'assigns @survey' do
      subject
      assigns(:survey).should_not be_nil
    end
    it 'assigns @responses' do
      subject
      assigns(:responses).should_not be_nil
    end
    it 'should send data' do
      controller.should_receive(:send_data).and_return{ controller.render nothing: true }
      subject
    end

    context 'filtering by school' do
      subject { get :survey, id: survey.id, export: { target_contact_relationship_contact_id_b: create(:school).civicrm_id } }

      it 'assigns @school' do
        subject
        assigns(:school).should_not be_nil
      end
    end
  end

end
