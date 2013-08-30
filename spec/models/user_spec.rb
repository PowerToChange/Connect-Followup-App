require 'spec_helper'

describe User do

  let!(:survey) { create(:survey_without_callbacks, activity_type_id: ActivityType::PETITION_TYPE_ID) }
  let(:user) { create(:user, surveys: [survey]) }
  let!(:lead_1) { create(:lead, survey_id: survey.id, user_id: user.id, response_id: '104122', contact_id: 60051) }
  let!(:lead_2) { create(:lead, survey_id: survey.id, user_id: user.id, response_id: '104124', contact_id: 60053) }

  describe '#connections', :vcr do
    subject { user.connections }

    context 'user has no leads' do
      before do
        user.leads.each(&:destroy)
      end
      it 'returns an array' do
        subject.should be_a_kind_of(Array)
      end
    end

    context 'user has some leads' do
      it 'returns an array' do
        subject.should be_a_kind_of(Array)
      end
      it 'returns 1 object' do
        subject.size.should == 1
      end
      it 'returns correct survey' do
        subject.first.survey.should == survey
      end
      it 'returns 1 survey with 2 responses' do
        subject.first.responses.size.should == 2
      end
      it 'returns correct responses' do
        subject.first.responses.collect(&:response_id).should =~ ['104122','104124']
      end
    end
  end

  describe '#sync_from_pulse', :vcr do
    let(:user) { create(:user, civicrm_id: 1, schools: []) }
    let(:school_1) { create(:school, pulse_id: 1) }
    let(:school_2) { create(:school, pulse_id: 2) }
    let(:school_3) { create(:school, pulse_id: 3) }

    before do
      school_1
      school_2
      school_3
      Pulse::MinistryInvolvement.stub(:where).and_return([
          double(user: { civicrm_id: 34904383 },
                 ministry: { campus: [{ campus_id: 1 }] },
                 role: { name: 'Team Member' }),
          double(user: { civicrm_id: 34904383 },
                 ministry: { campus: [{ campus_id: 2 }] },
                 role: { name: 'Student Leader' }),
          double(user: { civicrm_id: 34904383 },
                 ministry: { campus: [{ campus_id: 3 }] },
                 role: { name: 'Student' })
        ])
    end

    subject { user.sync_from_pulse }

    it 'associates schools to the user' do
      user.schools.should eq []
      subject
      user.schools.should eq [school_1, school_2]
    end

    it 'does not associate schools on ministry involvements with invalid roles' do
      user.schools.should eq []
      subject
      user.schools.should_not include(school_3)
    end

    it 'removes all schools if user not found in Pulse' do
      Pulse::MinistryInvolvement.stub(:where).and_raise(Pulse::Errors::BadRequest)
      user.schools << school_1
      user.schools.should be_present
      subject
      user.schools.should be_blank
    end

    it 'should still return if Pulse fails' do
      Pulse::MinistryInvolvement.stub(:where).and_raise(Pulse::Errors::InternalError)
      subject
    end

    it 'should set the civicrm_id from the Pulse' do
      user.civicrm_id.should eq 1
      subject
      user.civicrm_id.should be_present
      user.civicrm_id.should_not eq 1
    end
  end

end
