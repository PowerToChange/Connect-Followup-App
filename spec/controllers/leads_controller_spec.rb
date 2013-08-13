require 'spec_helper'

describe LeadsController do
  login_user
  describe "PUT /surveys/:id/leads/:id", :vcr do
    let(:survey) { create(:survey_without_callbacks) }
    let!(:lead) { create(:lead, survey: survey, status_id: 4) }

    context 'when updating status' do
      let(:status) { 3 }
      subject { put :update, survey_id: survey.id, id: lead.id, lead: { status_id: status } }
      it 'assigns correct @lead' do
        subject
        assigns(:lead).should == lead
      end
      context 'when update status to 3 (WIP)' do
        it 'redirects back to lead page' do
          subject
          response.should redirect_to(survey_lead_path(survey, lead))
        end
        it 'sets flash notice message' do
          subject
          flash[:notice].should_not be_empty
        end
      end
      context 'when update status to 4 (UNCONTACTED)' do
        let(:status) { 4 }
        it 'redirects back to lead page' do
          subject
          response.should redirect_to(survey_lead_path(survey, lead))
        end
        it 'sets flash notice message' do
          subject
          flash[:notice].should_not be_empty
        end
      end
      context 'when update status to 2 (COMPLETED)' do
        let(:status) { 2 }
        it 'redirects to reporting page' do
          subject
          response.should redirect_to(report_survey_lead_path(survey,lead))
        end
        it 'should not update' do
          Lead.any_instance.should_not_receive(:update_attributes)
          subject
        end
      end
    end

    context 'when updating status via JSON' do
      subject { put :update, survey_id: survey.id, id: lead.id, lead: { status_id: 2, engagement_level: 10 }, format: :json }
      it 'responds with head ok' do
        subject
        response.should be_success
        response.body.should be_blank
      end
      context 'when error updating lead' do
        before do
          Lead.any_instance.stub(:update_attributes) { false }
          Lead.any_instance.stub(:errors) { double(full_messages: ["Problem saving lead"]) }
        end
        it 'returns http status 400' do
          subject
          response.response_code.should == 400
        end
        it 'returns json response with error message' do
          subject
          response.body.should == "Problem saving lead"
        end
      end
    end

    context 'when updating status via javascript', js: true do
      let(:status) { 3 }
      subject { put :update, survey_id: survey.id, id: lead.id, lead: { status_id: status }, format: :js }
      it 'assigns correct @lead' do
        subject
        assigns(:lead).should == lead
      end
      context 'when update status to 3 (WIP)' do
        it 'sets flash notice message' do
          subject
          flash[:notice].should_not be_empty
        end
      end
      context 'when update status to 4 (UNCONTACTED)' do
        let(:status) { 4 }
        it 'sets flash notice message' do
          subject
          flash[:notice].should_not be_empty
        end
      end
      context 'when update status to 2 (COMPLETED)' do
        let(:status) { 2 }
        it 'redirects to reporting page' do
          subject
          response.body.should include(survey_lead_path(survey, lead))
        end
        it 'should not update' do
          Lead.any_instance.should_not_receive(:update_attributes)
          subject
        end
      end
    end

  end

  describe "DELETE /surveys/:id/leads/:id", :vcr do
    let(:survey) { create(:survey_without_callbacks) }
    let!(:lead) { create(:lead, survey: survey, status_id: 4) }

    subject { delete :destroy, survey_id: survey.id, id: lead.id, format: :js }

    it 'should destroy the lead' do
      Lead.where(id: lead.id).should be_present
      expect { subject }.to change { survey.leads.count }.from(1).to(0)
      Lead.where(id: lead.id).should be_blank
    end
    it 'should set the flash if successful' do
      subject.should be_success
      flash[:notice].should_not be_empty
    end
    it 'should set the flash if failure' do
      Lead.any_instance.stub(:destroy).and_return(false)
      subject.should be_success
      flash[:notice].should be_blank
      flash[:error].should be_present
    end

    context 'html' do
      subject { delete :destroy, survey_id: survey.id, id: lead.id, format: :html }
      it 'should redirect to the response' do
        subject.should redirect_to(survey_contact_response_path(survey_id: lead.survey_id, contact_id: lead.contact_id, id: lead.response_id))
      end
    end
  end

  describe "POST /surveys/:id/leads", :vcr do
    let(:survey) { create(:survey_without_callbacks) }
    let(:contact_id) { 1234 }
    let(:response_id) { 567890 }
    subject { post :create, survey_id: survey.id, lead: { response_id: response_id, contact_id: contact_id }, format: :js }

    it 'should create the lead' do
      subject
      Lead.where(survey_id: survey.id, response_id: 567890, contact_id: 1234).first.should be_present
    end
    it 'should set the flash if successful' do
      subject.should be_success
      flash[:notice].should be_present
      flash[:error].should be_blank
    end
    it 'should set the flash if failure' do
      Lead.any_instance.stub(:save).and_return(false)
      subject.should be_success
      flash[:notice].should be_blank
      flash[:error].should be_present
    end

    context 'html' do
      subject { post :create, survey_id: survey.id, lead: { response_id: 567890, contact_id: 1234 }, format: :html }
      it 'should redirect to the response' do
        subject.should redirect_to(survey_contact_response_path(survey_id: survey.id, contact_id: contact_id, id: response_id))
      end
    end
  end
end
