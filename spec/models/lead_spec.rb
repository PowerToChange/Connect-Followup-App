require 'spec_helper'

describe Lead do
  describe '#status', :vcr do
    let(:survey) { create(:survey_without_callbacks) }
    let!(:lead) { create(:lead, :survey => survey, :status_id => status) }
    subject { lead.status }
    context 'when status id 4' do
      let(:status) { 4 }
      it 'returns Uncontacted' do
        subject.should == 'Uncontacted'
      end
    end
    context 'when status id 3' do
      let(:status) { 3 }
      it 'returns Uncontacted' do
        subject.should == 'WIP'
      end
    end
    context 'when status id 2' do
      let(:status) { 2 }
      it 'returns Completed' do
        subject.should == 'Completed'
      end
    end
  end

  describe '#save' do

    let(:survey) { create(:survey_without_callbacks) }

    context 'when creating new lead' do
      let(:lead) { build(:lead, :survey => survey) }
      subject { lead.save }
      it 'does not call update_status_engagement_level_to_civicrm' do
        lead.should_not_receive(:update_status_engagement_level_to_civicrm)
        subject
      end
    end

    context 'when updating status & engagement level', :vcr do
      let!(:lead) { create(:lead, :survey => survey) }
      subject { lead.save }
      before do
        lead.status_id = 2
        lead.engagement_level = 8
      end
      it 'set engagement level of lead' do
        subject
        lead.engagement_level.should == 8
      end
      it 'set status id of lead' do
        subject
        lead.status_id.should == 2
      end
      it 'updates CiviCrm Activity' do
        CiviCrm::Activity.any_instance.should_receive(:save)
        subject
      end
    end

  end
end