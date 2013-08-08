require 'spec_helper'

describe NotesController do
  login_user

  let(:lead) { create(:lead, user: user) }
  let(:survey) { lead.survey }

  describe 'create', :vcr do
    subject { post :create, survey_id: survey.id, contact_id: lead.contact_id, note: 'Pls pick up some milk on your way home', format: :js }

    before do
      Note.any_instance.stub(:save).and_return(true)
    end

    context 'when success' do
      it 'should return successfully' do
        subject
        response.should be_success
      end
      it 'should create new note' do
        Note.any_instance.should_receive(:save)
        subject
      end
      it 'sets flash success' do
        subject
        flash[:success].should_not be_empty
      end
    end

    context 'when fail' do
      before do
        Note.any_instance.stub(:save).and_return(false)
      end
      it 'responds successfully' do
        subject
        response.should be_success
      end
      it 'sets flash error' do
        subject
        flash[:error].should_not be_empty
      end
    end

  end
end
