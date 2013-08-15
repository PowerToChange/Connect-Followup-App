require 'spec_helper'

describe ActivitiesController do
  login_user

  let(:response_id) { 24309 }
  let(:contact_id) { 32490 }
  let(:survey) { create(:survey) }

  describe 'create', :vcr do
    let(:activity_params) { { activity_type_id: 2 }  }

    subject { post :create, survey_id: survey.id, contact_id: contact_id, response_id: response_id, activity: activity_params, format: :js }

    before do
      Response.any_instance.stub(:id) { response_id }
    end

    context 'when success' do
      before do
        Activity.any_instance.stub(:save).and_return(true)
        Activity.any_instance.stub(:persisted?).and_return(true)
      end

      it 'responds successfully' do
        subject
        response.should be_success
      end
      it 'sets flash success' do
        subject
        flash[:success].should_not be_empty
      end
      it 'should initialize a lead' do
        subject
        assigns[:lead].should be_present
      end
      it 'should create a lead if no associated lead exists' do
        Lead.where(response_id: response_id).first.should be_blank
        subject
        Lead.where(response_id: response_id).first.should be_present
      end
      it 'should not create a lead if an associated lead already exists' do
        Lead.create(response_id: response_id, contact_id: contact_id, survey_id: survey.id, user_id: user.id)
        expect { subject }.to_not change { Lead.where(response_id: response_id).first.updated_at }
      end
    end

    context 'when fail' do
      before do
        Activity.any_instance.stub(:save).and_return(false)
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
