require 'spec_helper'

describe CustomField do
  let!(:survey) { create(:survey_without_callbacks, survey_id: 2) }

  describe '.sync', :vcr do
    let!(:custom_field) { create(:custom_field, survey: survey, custom_field_id: 1, label: 'Full Name', option_group_id: 2) }
    let(:field_a) { double(id: 1, label: 'Name', option_group_id: 5) }
    let(:field_b) { double(id: 11, label: 'Age', option_group_id: 3) }
    subject { CustomField.sync(survey) }

    before do
      CustomField.stub(:field_ids) { ["1","11"] }
      CiviCrm::CustomField.stub(:find).with("1") { field_a }
      CiviCrm::CustomField.stub(:find).with("11") { field_b }
    end

    it 'fetches field label twice from CiviCrm' do
      CiviCrm::CustomField.should_receive(:find).twice
      subject
    end
    it 'creates new field records' do
      expect { subject }.to change { survey.reload.custom_fields.count }.by(1)
    end
    it 'update existing field record' do
      expect { subject }.to change { custom_field.reload.label }.from('Full Name').to('Name')
    end
  end

  describe '.survey_fields' do
    subject { CustomField.send(:survey_fields) }
    before do
      CustomField.survey = survey
    end
    it 'fetches fields for survey from CiviCrm' do
      CiviCrm::CustomSurveyFields.should_receive(:where).with(hash_including(survey_id: 2, rowCount: 1000))
      subject
    end
  end

  describe '.option_values', :vcr do
    let(:custom_field) { create(:custom_field, survey: survey, custom_field_id: 1, label: 'Full Name', option_group_id: 999) }
    subject { custom_field.send(:option_values) }

    it 'fetches option values from CiviCrm' do
      CiviCrm::OptionValue.should_receive(:where).with(hash_including(option_group_id: 999, rowCount: 1000))
      subject
    end

    it 'memoizes result' do
      subject
      CiviCrm::OptionValue.should_not_receive(:where)
      subject
    end
  end

  describe '.label_for_option_value' do
    let(:custom_field) { create(:custom_field, survey: survey, custom_field_id: 1, label: 'Full Name', option_group_id: 999) }
    before { custom_field.stub(:option_values).and_return([double(value: 'value-wrong', label: 'boo'), double(value: 'value-test', label: 'yipee')]) }
    subject { custom_field.send(:label_for_option_value, 'value-test') }

    it 'should return the correct label' do
      subject.should eq 'yipee'
    end
  end
end