require 'spec_helper'

describe CustomField do
  describe '.sync' do
    let!(:survey) { create(:survey_without_callbacks, :custom_group_id => 9) }
    subject { CustomField.sync(survey) }
    it 'fetches custom fields from civicrm', :vcr do
      CiviCrm::CustomField.should_receive(:where).with(:custom_group_id => 9, :rowCount => 1000).and_return([])
      subject
    end
    it 'creates new custom field records', :vcr do
      expect { subject }.to change { survey.custom_fields.count }.by(16)
    end
    context 'when syncing existing fields' do
      let!(:custom_field_1) { create(:custom_field, :survey_id => survey.id, :custom_field_id => 64, :label => "Are you A?") }
      let!(:custom_field_2) { create(:custom_field, :survey_id => survey.id, :custom_field_id => 65, :label => "Are you B?") }
      let(:custom_field_1_updated) { double(:id => 64, :label => "Where are you A?") }
      let(:custom_field_2_updated) { double(:id => 65, :label => "Where are you B?") }
      before do
        CiviCrm::CustomField.stub(:where).and_return([custom_field_1_updated,custom_field_2_updated])
      end
      it 'updates record if there are differences' do
        expect { subject }.to change { custom_field_1.reload.label }.from('Are you A?').to('Where are you A?')
      end
      it 'removes record if no longer exist' do
        pending("removes custom field record if no longer exist")
      end
    end
  end
end
