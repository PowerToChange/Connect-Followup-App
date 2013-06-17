require 'spec_helper'

describe User do
  describe '#connections', :vcr do
    let(:user) { create(:user) }
    let!(:survey) { create(:survey_without_callbacks, :activity_type_id => 32) }
    let!(:survey_user) { create(:survey_user, :user_id => user.id, :survey_id => survey.id) }
    let!(:lead_1) { create(:lead, :survey_id => survey.id, :user_id => user.id, :response_id => '102052') }
    let!(:lead_2) { create(:lead, :survey_id => survey.id, :user_id => user.id, :response_id => '102053') }
    subject { user.connections }
    it 'returns an array' do
      subject.should be_a_kind_of(Array)
    end
    it 'returns 1 survey - leads objects' do
      subject.size.should == 1
    end
    it 'returns correct survey' do
      subject.first.survey.should == survey
    end
    it 'returns 1 survey with 2 leads' do
      subject.first.leads.size.should == 2
    end
    it 'returns correct leads' do
      subject.first.leads.collect{|l| l.response.response_id }.should =~ ['102052','102053']
    end
  end
end
