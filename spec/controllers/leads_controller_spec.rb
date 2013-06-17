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

  describe 'PUT /leads/:id' do
    context 'when updating progress' do
      let(:survey) { create(:survey_without_callbacks) }
      let!(:lead) { create(:lead, :survey => survey, :response_id => '123') }
      subject { put :update, :survey_id => survey.id, :id => lead.id, :lead => { :status_id => status } }
      context 'as Uncontacted' do
        let(:status) { 4 }
        it 'redirects back' do
          subject
          response.should redirect_to(survey_response_path(survey,:id => '123'))
        end
        it 'sends a flash notice message' do
          subject
          flash[:notice].should_not be_empty
        end
      end
      context 'as WIP' do
        let(:status) { 3 }
        it 'redirects back' do
          subject
          response.should redirect_to(survey_response_path(survey,:id => '123'))
        end
        it 'sends a flash notice message' do
          subject
          flash[:notice].should_not be_empty
        end
      end
      context 'as Completed' do
        let(:status) { 2 }
        it 'redirects to screen 6 - How did it go?' do
          subject
          response.should redirect_to(report_survey_lead_path(survey,lead))
        end
      end
    end
  end

  describe 'GET /leads/:id/report', :vcr do
    let(:survey) { create(:survey_without_callbacks) }
    let!(:lead) { create(:lead, :survey => survey, :response_id => '123') }
    subject { get :report, :survey_id => survey.id, :id => lead.id }
    it { should be_success }
  end
end
