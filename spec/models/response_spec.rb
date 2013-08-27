require 'spec_helper'

describe Response, :vcr do
  let!(:survey) { create(:survey_without_callbacks) }
  let!(:field) { create(:field, custom_field_id: 61, survey_id: survey.id, label: "I am an international student") }

  let(:contact) { CiviCrm::Contact.new(id: 11, display_name: 'Adrian Teh', email: 'adrian@ballistiq.com') }
  let(:relationship) { CiviCrm::Relationship.new(id: 11, contact_id: create(:school).civicrm_id) }

  let(:activity_attributes) { {}.tap { |this| survey.fields.each { |f| this[f.field_name] = f.field_name } } }
  let(:activity) { double({ id: 1, contacts: [contact], relationships: [relationship] }.merge(activity_attributes)) }

  let(:response) { Response.new(survey, activity) }

  let(:lead) { create(:lead, survey: survey, response_id: response.id) }

  describe '#answers' do
    subject { response.answers }

    it 'returns an array of question-answer object' do
      subject.each { |a| a.should respond_to(:label) }
      subject.each { |a| a.should respond_to(:answer) }
    end
  end

  describe '#find' do
    subject { Response.find(survey: survey, id: 12345) }
    let!(:field) { create(:field, custom_field_id: 61, survey_id: survey.id, label: "I am an international student") }

    before do
      CiviCrm::Activity.stub_chain(:where, :includes, :first).and_return(double(contacts: [Contact.new]))
    end

    it 'calls civicrm api' do
      CiviCrm::Activity.should_receive(:where).with(hash_including("return" => "target_contact_id", :id=>12345))
      subject
    end
    it 'returns a response' do
      subject.should be_a_kind_of(Response)
    end
    it 'initializes the contact' do
      subject.contact.should be_a(Contact)
    end
  end

  describe '#lead' do
    subject { response.lead }
    before { lead }

    it 'should return the associated lead' do
      subject.should be_a(Lead)
      subject.id.should eq(lead.id)
    end
  end

  describe '#initialize_and_preset_by_survey_and_contact_and_activity' do
    let(:activity) { double(id: 1, custom_64: "Montreal", target_contact_id: [11]) }
    let(:activity_two) { double(id: 2, custom_64: "Hamilton", target_contact_id: [222]) }

    before do
      contact.stub(:activities).and_return([activity_two, activity])
      contact.stub(:relationships).and_return([double(relationship_type_id: Relationship::SCHOOL_CURRENTLY_ATTENDING_TYPE_ID, contact_id_b: create(:school).civicrm_id)])
    end

    context 'activity is an instance of activity' do
      subject { Response.initialize_and_preset_by_survey_and_contact_and_activity(survey, contact, activity) }

      it 'should return a response' do
        subject.should be_a(Response)
      end
      it 'should set the correct activity on the response' do
        subject.id.should eq activity.id
      end
      it 'should set the school on the response' do
        subject.school.should be_present
      end
    end

    context 'activity is an activity id' do
      subject { Response.initialize_and_preset_by_survey_and_contact_and_activity(survey, contact, activity.id) }

      it 'should return a response' do
        subject.should be_a(Response)
      end
      it 'should set the correct activity on the response' do
        subject.id.should eq activity.id
      end
      it 'should set the school on the response' do
        subject.school.should be_present
      end
    end
  end
end