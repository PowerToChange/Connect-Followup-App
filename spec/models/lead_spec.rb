require 'spec_helper'

describe Lead, :vcr do
  describe '#status' do
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
        subject.should == 'In Progress'
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
      it 'should assign activity in CiviCrm' do
        CiviCrm::Activity.should_receive(:update).with(hash_including(id: lead.response_id, assignee_contact_id: lead.user.civicrm_id))
        subject
      end
      it 'should not create two leads with the same response_id' do
        subject
        lead2 = build(:lead, response_id: lead.response_id, user_id: lead.user_id + 1)
        lead2.valid?.should be_false
        lead2.response_id = lead2.response_id.to_i + 1
        lead2.valid?.should be_true
      end
    end

    context 'when updating status & engagement level', :vcr do
      let!(:lead) { create(:lead, survey: survey) }
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
        CiviCrm::Activity.should_receive(:update).with(hash_including(id: lead.response_id))
        subject
      end
      it 'create note history' do
        Note.should_receive(:create).at_least(:once).with(hash_including(contact_id: lead.contact_id)).and_call_original
        subject
      end
    end
  end

  describe 'destroy' do
    let(:lead) { create(:lead, contact_id: 60058, response_id: 104210, user: create(:user)) }
    subject { lead.destroy }

    it 'should unassign activity in CiviCrm' do
      CiviCrm::Activity.should_receive(:update).at_least(:once).with(hash_including(id: lead.response_id, assignee_contact_id: User::DEFAULT_CIVICRM_ID))
      subject
    end
  end

  describe '#find_and_preset_all_by_leads' do
    let(:lead) { create(:lead, contact_id: 60058, response_id: 104210, user: create(:user)) }

    subject { Lead.find_and_preset_all_by_leads([lead]) }

    it 'should return an array of leads' do
      subject.should be_a(Array)
      subject.each { |l| l.should be_a(Lead) }
    end

    it "should set the lead's contact" do
      subject.each { |l| l.contact.should be_present }
    end

    it "should set the lead's response" do
      subject.each { |l| l.response.should be_present }
    end

    it "should return an empty array if no lead ids given" do
      Lead.find_and_preset_all_by_leads([]).should eq []
      Lead.find_and_preset_all_by_leads(nil).should eq []
      Lead.find_and_preset_all_by_leads('').should eq []
    end
  end
end