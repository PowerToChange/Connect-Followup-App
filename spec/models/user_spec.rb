require 'spec_helper'

describe User do

  describe '#connections', :vcr do
    let!(:survey) { create(:survey_without_callbacks, :activity_type_id => Survey::PETITION_ACTIVITY_TYPE_ID) }
    let(:user) { create(:user, :surveys => [survey]) }
    let!(:lead_1) { create(:lead, :survey_id => survey.id, :user_id => user.id, :response_id => '102052') }
    let!(:lead_2) { create(:lead, :survey_id => survey.id, :user_id => user.id, :response_id => '102053') }

    subject { user.connections }

    it 'returns an array' do
      subject.should be_a_kind_of(Array)
    end
    it 'returns 1 survey - leads objects' do
      subject.size.should == 1
    end
    it 'returns correct survey' do
      subject.first.survey.should == survey
    end
    it 'returns 1 survey with 2 leads' do
      subject.first.leads.size.should == 2
    end
    it 'returns correct leads' do
      subject.first.leads.collect{|l| l.response.response_id }.should =~ ['102052','102053']
    end
  end

  describe '.sync_from_pulse', :vcr do
    let(:user) { create(:user, civicrm_id: nil, schools: []) }
    let(:school) { create(:school, pulse_id: 1) }

    before do
      school
      Pulse::MinistryInvolvement.stub(:where).and_return([
          double(user: { civicrm_id: 34904383 },
                 ministry: { campus: [{ campus_id: 1 }, { campus_id: 2 }] })
        ])
    end

    subject { user.sync_from_pulse }

    it 'associates schools to the user' do
      user.schools.should eq []
      subject
      user.schools.should eq [school]
    end

    it 'removes all schools if user not found in Pulse' do
      Pulse::MinistryInvolvement.stub(:where).and_raise(Pulse::Errors::BadRequest)
      user.schools << school
      user.schools.should be_present
      subject
      user.schools.should be_blank
    end

    it 'should still return if Pulse fails' do
      Pulse::MinistryInvolvement.stub(:where).and_raise(Pulse::Errors::InternalError)
      subject
    end

    it 'should set the civicrm_id from the Pulse' do
      user.civicrm_id.should be_blank
      subject
      user.civicrm_id.should be_present
    end
  end

end
