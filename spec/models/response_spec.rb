require 'spec_helper'

describe Response do
  let!(:survey) { create(:survey_without_callbacks) }
  let!(:custom_field) { create(:custom_field, :custom_field_id => 64, :survey_id => survey.id, :label => "Where are you?") }
  let(:answer) { double(:id => 1, :custom_64 => "Montreal", :target_contact_id => [11]) }
  let(:response) { Response.new(survey,answer) }

  describe '#answers', :vcr do
    subject { response.answers }
    it 'returns an array of question-answer object' do
      subject.first.should respond_to(:label)
      subject.first.should respond_to(:answer)
    end
    it 'calls CiviCrm::CustomValue with correct params' do
      CiviCrm::CustomValue.should_receive(:where).with(hash_including(entity_id: answer.id, rowCount: 1000, 'return.custom_64' => 1)) { [] }
      subject
    end
  end

  describe '#contact' do
    subject { response.contact }
    it 'fetches contact from civicrm' do
      contact = CiviCrm::Contact.new(:id => 11, :display_name => 'Adrian Teh',:email => 'adrian@ballistiq.com')
      CiviCrm::Contact.should_receive(:find).with(11).and_return(contact)
      subject
    end
  end

  describe '.find' do
    subject { Response.find(:survey => survey, :id => 12345) }
    let!(:custom_field) { create(:custom_field, :custom_field_id => 64, :survey_id => survey.id, :label => "Where are you?") }
    before do
      CiviCrm::Activity.stub_chain(:where, :first).and_return(double())
    end
    it 'calls civicrm api' do
      CiviCrm::Activity.should_receive(:where).with(hash_including("return" => "target_contact_id", :id=>12345))
      subject
    end
    it 'returns a response' do
      subject.should be_a_kind_of(Response)
    end
  end
end