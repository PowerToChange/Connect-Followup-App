require 'spec_helper'

describe Note do
  let(:user) { build(:user) }

  describe '::user_stamp', :vcr do
    subject { Note.user_stamp(user) }

    it 'should return a String' do
      subject.should be_a String
    end
    it 'should have the user email' do
      subject.should include user.email
    end
  end
end