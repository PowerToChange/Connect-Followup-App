require 'spec_helper'

describe Survey do
  describe '#save' do
    context 'when creating new survey' do
      subject { Survey.create(:activity_type_id => 32) }
      let(:custom_group) { [OpenStruct.new(:title => 'September Launch 2012', :id => 9)] }
      before do
        CiviCrm::CustomGroup.stub(:where).and_return(custom_group)
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
    end
    context 'when fetching existing survey', :vcr do
      let!(:survey) { create(:survey, :title => 'September Launch 2012') }
      let(:custom_group) { [OpenStruct.new(:title => 'November Launch 2012', :id => 9)] }
      subject { survey.save }
      before do
        CiviCrm::CustomGroup.stub(:where).and_return(custom_group)
      end
      it 'updates title' do
        expect { subject }.to change { survey.title }.from('September Launch 2012').to('November Launch 2012')
      end
    end
  end
end
