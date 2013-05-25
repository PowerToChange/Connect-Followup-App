require 'spec_helper'

describe Survey do
  describe '#save' do
    let(:custom_group) { OpenStruct.new(:title => title, :id => 9) }
    before do
      CustomField.stub(:sync)
    end
    context 'when creating new survey' do
      let(:survey) { build(:survey, :activity_type_id => 32) }
      subject { survey.save }
      let(:title) { 'September Launch 2012' }
      before do
        CiviCrm::CustomGroup.stub_chain(:where,:first).and_return(custom_group)
      end
      it 'fetches survey record from Civicrm' do
        CiviCrm::CustomGroup.should_receive(:where).with(hash_including(:extends_entity_column_value => 32))
        subject
      end
      it 'updates title' do
        subject
        Survey.last.title.should_not be_nil
      end
      it 'updates custom_group_id' do
        subject
        Survey.last.custom_group_id.should_not be_nil
      end
      it 'fetches custom field records from Civicrm' do
        CustomField.should_receive(:sync).with(an_instance_of(Survey))
        subject
      end
      context 'when survey does not exist' do
        let(:custom_group) { double(:count => 0, :id => nil, :title => nil) }
        it 'returns error' do
          CiviCrm::CustomGroup.stub_chain(:where,:first).and_return(custom_group)
          subject
          survey.errors.full_messages.should_not be_empty
        end
        it 'should not save' do
          expect { subject }.to change { Survey.count }.by(0)
        end
      end
    end
    context 'when fetching existing survey', :vcr do
      let!(:survey) { create(:survey, :title => 'September Launch 2012') }
      let(:title) { 'November Launch 2012' }
      subject { survey.save }
      before do
        CiviCrm::CustomGroup.stub_chain(:where,:first).and_return(custom_group)
      end
      it 'updates title' do
        expect { subject }.to change { survey.title }.from('September Launch 2012').to('November Launch 2012')
      end
    end
  end

  describe '#responses' do
    let(:survey) { create(:survey_without_callbacks, :activity_type_id => 32) }
    let!(:custom_field) { create(:custom_field, :custom_field_id => 64, :survey_id => survey.id) }
    let(:act_1) { double() }
    let(:act_2) { double() }
    subject { survey.responses }
    before do
      CiviCrm::Activity.stub(:where).and_return([act_1,act_2])
    end
    it 'fetches activities from civicrm' do
      CiviCrm::Activity.should_receive(:where).with(hash_including(:activity_type_id => 32, 'return.custom_64' => 1))
      subject
    end
    it 'returns an array' do
      subject.should be_a_kind_of(Array)
    end
    it 'returns an array of Response objects' do
      subject.first.should be_a_kind_of(Response)
    end
    it 'returns an array with 2 response objects' do
      subject.size.should == 2
    end
  end
end
