require 'spec_helper'

describe ActivitiesController do
  login_user

  let(:lead) { create(:lead, user: user, contact_id: 2) }
  let(:survey) { lead.survey }

  describe 'create', :vcr do
    let(:activity_params) { { activity_type_id: 2 }  }

    subject { post :create, survey_id: survey.id, contact_id: lead.contact_id, activity: activity_params, format: :js }

    before do
      Response.any_instance.stub(:id) { lead.response_id }
    end

    context 'when success' do
      before do
        Activity.any_instance.stub(:save).and_return(true)
      end
      it 'responds successfully' do
        subject
        response.should be_success
      end
      it 'sets flash success' do
        subject
        flash[:success].should_not be_empty
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
