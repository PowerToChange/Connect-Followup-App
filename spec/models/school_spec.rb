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

end
