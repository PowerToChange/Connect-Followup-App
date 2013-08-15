require 'spec_helper'

describe Activity do
  subject { Activity.new(source_contact_id: 48973,
                         activity_type_id: ActivityType::PHONE_CALL_TYPE_ID,
                         status_id: Activity::STATUS_COMPLETED_ID,
                         target_contact_id: 89043,
                         details: 'Details details') }

  describe '#is_rejoiceable?' do
    it 'should not be a rejoiceable' do
      subject.is_rejoiceable?.should be_false
    end
  end

  describe 'rejoiceables' do
    subject { Activity.new(source_contact_id: 48973,
                           activity_type_id: ActivityType::REJOICEABLE_TYPE_ID,
                           status_id: Activity::STATUS_COMPLETED_ID,
                           target_contact_id: 89043,
                           details: 'Details details',
                           CiviCrm.custom_fields.activity.rejoiceable.rejoiceable_id => '1',
                           CiviCrm.custom_fields.activity.rejoiceable.survey_id => '438934',
                           subject: 'Happy happy happy') }

    describe '#is_rejoiceable?' do
      it 'should be a rejoiceable' do
        subject.is_rejoiceable?.should be_true
      end
    end

    describe 'validation' do
      it 'should have a rejoiceable id' do
        rej = subject
        rej.should be_valid
        rej.send("#{ CiviCrm.custom_fields.activity.rejoiceable.rejoiceable_id }=", nil)
        rej.should_not be_valid
      end

      it 'should have a survey id' do
        rej = subject
        rej.should be_valid
        rej.send("#{ CiviCrm.custom_fields.activity.rejoiceable.survey_id }=", nil)
        rej.should_not be_valid
      end

      it 'should have a subject' do
        rej = subject
        rej.should be_valid
        rej.send("subject=", nil)
        rej.should_not be_valid
      end
    end
  end

end