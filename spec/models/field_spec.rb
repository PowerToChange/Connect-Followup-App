require 'spec_helper'

describe Field, :vcr do
  let!(:survey) { create(:survey_without_callbacks, survey_id: 2) }

  describe '.sync' do
    let!(:field) { create(:field, survey: survey, custom_field_id: 1, field_name: 'name', label: 'Full Name', option_group_id: 2) }

    let(:civicrm_custom_field_a) { double(id: 1, label: 'Name', field_name: 'name', option_group_id: 5) }
    let(:civicrm_custom_field_b) { double(id: 11, label: 'Age', field_name: 'age', option_group_id: 3) }

    let(:civicrm_custom_survey_field_a) { double(custom_field_id: '1', field_name: 'name') }
    let(:civicrm_custom_survey_field_b) { double(custom_field_id: '11', field_name: 'age') }

    subject { Field.sync(survey) }

    before do
      Field.stub(:survey_fields) { [civicrm_custom_survey_field_a, civicrm_custom_survey_field_b] }
      CiviCrm::CustomField.stub(:find).with("1") { civicrm_custom_field_a }
      CiviCrm::CustomField.stub(:find).with("11") { civicrm_custom_field_b }
    end

    it 'fetches custom field from CiviCrm' do
      CiviCrm::CustomField.should_receive(:find).twice
      subject
    end
    it 'creates new field records' do
      expect { subject }.to change { survey.reload.fields.count }.by(1)
    end
    it 'replaces existing field record' do
      subject
      Field.where(id: field.id).all.should be_blank
      Field.where(field_name: field.field_name).all.should be_present
    end
  end

  describe '.survey_fields' do
    subject { Field.send(:survey_fields) }
    before do
      Field.survey = survey
    end
    it 'fetches fields for survey from CiviCrm' do
      CiviCrm::CustomSurveyFields.should_receive(:where).with(hash_including(survey_id: survey.survey_id, campaign_id: survey.campaign_id, activity_type_id: ActivityType::PETITION_TYPE_ID)).and_call_original
      subject
    end
  end

  describe '.option_values' do
    let(:field) { create(:field, survey: survey, custom_field_id: 1, label: 'Full Name', option_group_id: 999) }
    subject { field.send(:option_values) }

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
    let(:field) { create(:field, survey: survey, custom_field_id: 1, label: 'Full Name', option_group_id: 999) }
    before { field.stub(:option_values).and_return([double(value: 'value-wrong', label: 'boo'), double(value: 'value-test', label: 'yipee')]) }
    subject { field.send(:label_for_option_value, 'value-test') }

    it 'should return the correct label' do
      subject.should eq 'yipee'
    end
  end
end