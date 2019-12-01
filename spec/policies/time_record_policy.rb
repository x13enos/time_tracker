require 'rails_helper'

describe TimeRecordPolicy do

  context "actions create and all doesn't require any conditions" do
    let(:user) { build(:user) }

    subject { described_class.new(user, 'time_record') }

    it { is_expected.to permit_actions([:create, :daily]) }
  end

  context 'user was found and record belongs to user' do
    let(:time_record) { create(:time_record) }

    subject { described_class.new(time_record.user, time_record) }

    it { is_expected.to permit_actions([:update, :delete]) }
  end
end
