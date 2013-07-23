require 'spec_helper'

describe Survey do

  describe '#save' do
    let(:survey_response) { OpenStruct.new(:title => title, :campaign_id => 9, :activity_type_id => 32) }

    before do
      CustomField.stub(:sync)
    end

    context 'when creating new survey' do
      let(:survey) { build(:survey, :survey_id => 2) }
      subject { survey.save }
      let(:title) { 'Sept 2012 petition' }
      before do
        CiviCrm::Survey.stub_chain(:where,:first).and_return(survey_response)
      end
      it 'fetches survey record from Civicrm' do
        CiviCrm::Survey.should_receive(:where).with(hash_including(:id => 2))
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
        let(:survey_response) { double(:count => 0) }
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
      let!(:survey) { create(:survey, :title => 'Sept 2012 petition') }
      let(:title) { 'Nov 2012 petition' }
      subject { survey.save }
      before do
        CiviCrm::Survey.stub_chain(:where,:first).and_return(survey_response)
      end
      it 'updates title' do
        expect { subject }.to change { survey.title }.from('Sept 2012 petition').to('Nov 2012 petition')
      end
    end
  end

  describe 'has_all_schools' do
    let(:survey) { build(:survey, :survey_id => 2) }
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

  # describe '#responses' do
  #   let(:survey) { create(:survey_without_callbacks, :activity_type_id => 32) }
  #   let!(:custom_field) { create(:custom_field, :custom_field_id => 64, :survey_id => survey.id) }
  #   let(:act_1) { double(:count => nil, :target_contact_id => [1234], :custom_64 => 'Answer') }
  #   let(:act_2) { double(:count => nil, :target_contact_id => [1235], :custom_64 => 'Answer') }
  #   let(:act_3) { double(:count => 0) }
  #   subject { survey.responses }
  #   before do
  #     CiviCrm::Activity.stub(:where).and_return([act_1,act_2,act_3])
  #   end
  #   it 'fetches activities from civicrm' do
  #     CiviCrm::Activity.should_receive(:where).with(hash_including(:activity_type_id => 32, 'return.custom_64' => 1))
  #     subject
  #   end
  #   it 'returns an array' do
  #     subject.should be_a_kind_of(Array)
  #   end
  #   it 'returns an array of Response objects' do
  #     subject.first.should be_a_kind_of(Response)
  #   end
  #   it 'returns an array with 2 response objects' do
  #     subject.size.should == 2
  #   end
  # end
end
