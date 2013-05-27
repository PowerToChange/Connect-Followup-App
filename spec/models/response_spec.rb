require 'spec_helper'

describe Response do
  let!(:survey) { create(:survey_without_callbacks) }
  let!(:custom_field) { create(:custom_field, :custom_field_id => 64, :survey_id => survey.id, :label => "Where are you?") }
  let(:answer) { double(:custom_64 => "Montreal", :target_contact_id => [11]) }
  let(:response) { Response.new(survey,answer) }

  describe '#answers' do
    subject { response.answers }
    it 'returns an array of question-answer object' do
      subject.first.label.should == "Where are you?"
      subject.first.answer.should == "Montreal"
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
end