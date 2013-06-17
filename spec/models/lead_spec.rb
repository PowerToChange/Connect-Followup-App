require 'spec_helper'

describe Lead do
  describe '#status', :vcr do
    let!(:lead) { create(:lead, :status_id => status) }
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
end