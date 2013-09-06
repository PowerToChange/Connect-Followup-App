require 'spec_helper'

describe PtcActivityQuery, :vcr do
  let(:survey) { create(:survey_without_callbacks) }
  let(:activity_id) { 104134 }

  describe '.find_response_for_survey' do
    subject { PtcActivityQuery.find_response_for_survey(activity_id, survey) }

    it 'should return a Response' do
      subject.should be_a(Response)
    end

    describe 'response contact' do
      subject { PtcActivityQuery.find_response_for_survey(activity_id, survey).contact }

      it 'should initialize' do
        subject.should be_present
      end
      it 'should initialize the activities' do
        subject.activities.should be_present
        subject.activities.first.should be_a Activity
      end
      it 'should initialize the notes' do
        subject.notes.should be_present
        subject.notes.first.should be_a Note
      end
      it 'should initialize the relationships' do
        subject.relationships.should be_present
        subject.relationships.first.should be_a Relationship
      end
      it 'should return only school relationships' do
        subject.relationships.each do |r|
          r.relationship_type_id.to_i.should eq(Relationship::SCHOOL_CURRENTLY_ATTENDING_TYPE_ID)
        end
      end
    end
  end

  describe '.where_survey' do
    subject { PtcActivityQuery.where_survey(params, survey) }
    let(:params) { {} }

    it 'should return a Relation' do
      subject.should be_a(CiviCrm::Actions::Relation)
    end

    describe 'all' do
      subject { PtcActivityQuery.where_survey(params, survey).all }

      it 'should return PtcActivityQuery' do
        subject.first.should be_a(PtcActivityQuery)
      end
      it 'should initialize contact' do
        subject.first.contacts.should be_present
        subject.first.contacts.first.should be_a Contact
      end
      it 'should return responses to this survey' do
        subject.each do |activity|
          # These three attributes are used to request responses to a survey
          activity.source_record_id.to_i.should eq(survey.survey_id)
          activity.campaign_id.to_i.should eq(survey.campaign_id)
          activity.activity_type_id.to_i.should eq(ActivityType::PETITION_TYPE_ID)
        end
      end

      context 'with params_to_return_school' do
        subject { PtcActivityQuery.where_survey(params, survey).where(PtcActivityQuery.params_to_return_school) }

        it 'should initialize relationships' do
          subject.first.contacts.first.relationships.should be_present
          subject.first.contacts.first.relationships.first.should be_a Relationship
        end
        it 'should return only school relationships' do
          subject.first.contacts.first.relationships.each do |r|
            r.relationship_type_id.to_i.should eq(Relationship::SCHOOL_CURRENTLY_ATTENDING_TYPE_ID)
          end
        end
      end
    end
  end

  describe '.params_to_find_responses_to_survey' do
    subject { PtcActivityQuery.params_to_find_responses_to_survey(survey) }

    it 'should return a Hash' do
      subject.should be_a Hash
    end
  end

  describe '.params_to_return_school' do
    subject { PtcActivityQuery.params_to_return_school }

    it 'should return a Hash' do
      subject.should be_a Hash
    end
  end

  describe '.params_to_return_everything_about_a_contact_for_survey' do
    subject { PtcActivityQuery.params_to_return_everything_about_a_contact_for_survey(survey) }

    it 'should return a Hash' do
      subject.should be_a Hash
    end
  end
end