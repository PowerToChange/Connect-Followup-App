require 'spec_helper'

describe School do

  subject(:school) { build(:school) }
  let(:school_response) { OpenStruct.new(id: school.civicrm_id, external_id: school.pulse_id, display_name: school.display_name) }

  before do
    CiviCrm::Contact.stub_chain(:where, :first).and_return(school_response)
  end

  it 'fetches school contact record from Civicrm' do
    CiviCrm::Contact.should_receive(:find).with(school.civicrm_id)
    school.civicrm_school
  end

  it 'supports to_s' do
    school.to_s.should be_a(String)
  end

  context 'when syncing civicrm schools' do
    let!(:schools_response) do
      (1..5).collect { |i| OpenStruct.new(id: i, external_identifier: i, display_name: "School #{i}") }
    end

    before do
      CiviCrm::Contact.stub_chain(:where).and_return(schools_response)
    end

    it 'should fetch all schools from civicrm' do
      CiviCrm::Contact.should_receive(:where)
      School.all_civicrm_schools
    end

    it 'should sync all schools from civicrm' do
      school.save
      CiviCrm::Contact.should_receive(:where)
      School.sync_all_from_civicrm
      School.count.should eq(5)
      School.where(id: school.id).count.should eq(0)
    end
  end

  context '#find_by_relationship' do
    let(:relationship) { double(contact_id_b: school.civicrm_id) }
    subject { School.find_by_relationship(relationship) }

    before { school.save }

    it 'returns a school' do
      subject.should be_a(School)
    end

    it 'returns the correct school' do
      subject.civicrm_id.should eq relationship.contact_id_b
    end
  end

end
