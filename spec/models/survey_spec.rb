require 'spec_helper'

describe Survey do

  describe '#save', :vcr do
    let(:survey_response) { OpenStruct.new(title: title, campaign_id: 9, activity_type_id: ActivityType::PETITION_TYPE_ID) }

    before do
      CustomField.stub(:sync)
    end

    context 'when creating new survey', :vcr do
      let(:survey) { build(:survey, survey_id: 2) }
      subject { survey.save }
      let(:title) { 'Power survey - July21-1' }
      before do
        CiviCrm::Survey.stub_chain(:where,:first).and_return(survey_response)
      end
      it 'fetches survey record from Civicrm' do
        CiviCrm::Survey.should_receive(:where).with(hash_including(id: 2))
        subject
      end
      it 'updates title' do
        subject
        Survey.last.title.should_not be_nil
      end
      it 'updates campaign_id' do
        subject
        Survey.last.campaign_id.should_not be_nil
      end
      it 'updates activity_type_id' do
        subject
        Survey.last.activity_type_id.should_not be_nil
      end
      it 'fetches custom field records from Civicrm' do
        CustomField.should_receive(:sync).with(an_instance_of(Survey))
        subject
      end
      context 'when survey does not exist' do
        let(:survey_response) { nil }
        it 'returns error' do
          CiviCrm::Survey.stub_chain(:where,:first).and_return(survey_response)
          subject
          survey.errors.full_messages.should_not be_empty
        end
        it 'should not save' do
          expect { subject }.to change { Survey.count }.by(0)
        end
      end
    end

    context 'when fetching existing survey', :vcr do
      let!(:survey) { create(:survey, title: 'Power survey - July21-1') }
      let(:title) { 'Nov 2012 petition' }
      subject { survey.save }
      before do
        CiviCrm::Survey.stub_chain(:where,:first).and_return(survey_response)
      end
      it 'updates title' do
        expect { subject }.to change { survey.title }.from('Power survey - July21-1').to('Nov 2012 petition')
      end
    end
  end

  describe 'has_all_schools' do
    let(:survey) { build(:survey, survey_id: 2) }
    subject { survey.save }

    before do
      (1..5).each { |i| create(:school) }
      subject
    end

    it 'should be associated to all schools if has_all_schools', :vcr do
      survey.has_all_schools.should eq false
      survey.update_attribute :has_all_schools, true
      survey.schools.should eq School.all
    end

    it 'should not be associated to any schools if not has_all_schools', :vcr do
      survey.has_all_schools.should eq(false)
      survey.update_attribute :has_all_schools, true
      survey.update_attribute :has_all_schools, false
      survey.schools.should eq []
    end

    it 'should be associated to newly created schools if has_all_schools', :vcr do
      survey.has_all_schools.should eq(false)
      survey.update_attribute :has_all_schools, true
      survey.schools.should eq School.all
      create(:school)
      survey.reload.schools.should eq School.all
    end
  end

  describe '#responses', :vcr do
    let(:survey) { create(:survey_without_callbacks, activity_type_id: ActivityType::PETITION_TYPE_ID) }

    subject { survey.responses }

    it 'returns an array' do
      subject.should be_a_kind_of(Array)
    end
    it 'returns an array of Response objects' do
      subject.each { |r| r.should be_a_kind_of(Response) }
    end
    it 'should initialize the contact on each response' do
      subject.each { |r| r.contact.should be_a_kind_of(Contact) }
    end
  end
end
