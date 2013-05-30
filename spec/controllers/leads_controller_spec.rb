require 'spec_helper'

describe LeadsController do
  login_user
  describe 'POST /leads' do
    let!(:survey) { create(:survey_without_callbacks) }
    subject { post :create, :survey_id => survey.id, :lead => { :response_id => '12345' } }
    it 'creates a new lead for user' do
      expect { subject }.to change { user.reload.leads.count }.by(1)
    end
    it 'creates a new lead for survey' do
      expect { subject }.to change { survey.reload.leads.count }.by(1)
    end
    it 'returns a flash notice message' do
      subject
      flash[:notice].should_not be_empty
    end
    it 'redirects to survey show page' do
      subject
      response.should redirect_to(survey_path(survey))
    end
    context 'when invalid' do
      subject { post :create, :survey_id => survey.id, :lead => { :response_id => '' } }
      it 'does not create a new lead' do
        expect { subject }.to change { Lead.count }.by(0)
      end
      it 'returns a flash alert message' do
        subject
        flash[:alert].should_not be_empty
      end
      it 'redirects to survey show page' do
        subject
        response.should redirect_to(survey_path(survey))
      end
    end
  end
end
