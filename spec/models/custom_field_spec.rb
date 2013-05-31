require 'spec_helper'

describe CustomField do
  describe '.sync' do
    let!(:survey) { create(:survey_without_callbacks, :custom_group_id => 9) }
    let!(:custom_field) { create(:custom_field, :survey => survey, :custom_field_id => 1, :label => 'Full Name') }
    let(:fields) { [double(:id => 1, :label => 'Name'), double(:id => 11, :label => 'Age')] }
    subject { CustomField.sync(survey) }
    before do
      CiviCrm::CustomField.stub(:where).and_return(fields)
    end
    it 'fetches fields for survey from CiviCrm' do
      CiviCrm::CustomField.should_receive(:where).with(hash_including(:custom_group_id => 9, :rowCount => 1000))
      subject
    end
    it 'creates new field records' do
      expect { subject }.to change { survey.reload.custom_fields.count }.by(1)
    end
    it 'update existing field record' do
      expect { subject }.to change { custom_field.reload.label }.from('Full Name').to('Name')
    end
  end
end