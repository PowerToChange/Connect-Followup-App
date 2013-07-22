require 'spec_helper'

describe ResponsesController do
  login_user

  let(:lead) { create(:lead, user: user) }
  let(:survey) { lead.survey }

  after do
    flash[:error].should be_nil
  end

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

  describe 'create_rejoiceable' do
    subject { post :create_rejoiceable, survey_id: survey.id, id: lead.response_id, rejoiceable_id: 1 }

    before do
      Rejoiceable.any_instance.stub(:save).and_return(true)
    end

    it 'should return redirect', :vcr do
      subject
      response.should be_redirect
    end

    it 'should create new rejoiceable', :vcr do
      Rejoiceable.any_instance.should_receive(:save)
      subject
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
