require 'spec_helper'

describe ResponsesController do
  login_user

  let(:lead) { create(:lead, user: user) }
  let(:survey) { lead.survey }

  describe 'show' do
    subject { get :show, survey_id: survey.id, id: lead.response_id }

    it 'should return success', :vcr do
      subject
      response.should be_success
    end

    it 'assigns @lead', :vcr do
      subject
      assigns(:lead).should_not be_nil
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

  describe 'POST /survey/:id/responses', :vcr do
    let(:params) { { source_contact_id: 1, status_id: Lead::COMPLETED_STATUS_ID, activity_type_id: 2, details: 'adrian@ballistiq.com', target_contact_id: 2 }  }
    subject { post :create, survey_id: survey.id, id: lead.response_id, activity: params }
    before do
      Response.any_instance.stub(:id) { lead.response_id }
    end
    context 'when success' do
      before do
        Activity.any_instance.stub(:save).and_return(true)
      end
      it 'redirects' do
        subject
        response.should be_redirect
      end
      it 'sets flash success' do
        subject
        flash[:success].should_not be_empty
      end
    end
    context 'when fail' do
      let(:params) { { source_contact_id: 1, status_id: Lead::COMPLETED_STATUS_ID, details: 'adrian@ballistiq.com', target_contact_id: 2 }  }
      before do
        Activity.any_instance.stub(:save).and_return(false)
      end
      it 'redirects' do
        subject
        response.should be_redirect
      end
      it 'sets flash error' do
        subject
        flash[:error].should_not be_empty
      end
    end
  end

  describe 'create_note' do
    subject { post :create_note, survey_id: survey.id, id: lead.response_id, note: "Don't forget the milk" }

    before do
      Note.any_instance.stub(:save).and_return(true)
    end

    it 'should return redirect', :vcr do
      subject
      response.should be_redirect
    end

    it 'should create new note', :vcr do
      Note.any_instance.should_receive(:save)
      subject
    end
  end
end
