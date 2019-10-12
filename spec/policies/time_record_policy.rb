require 'rails_helper'

describe TimeRecordPolicy do

  context 'user was found' do
    subject { described_class.new(create(:user), :time_record) }

    it { is_expected.to permit_actions([:create, :all]) }
  end

  context 'user was not found' do
    subject { described_class.new(nil, :time_record) }

    it { is_expected.to forbid_actions([:create, :update, :all]) }
  end

  context 'user was found and record belongs to user' do
    let(:time_record) { create(:time_record) }

    subject { described_class.new(time_record.user, time_record) }

    it { is_expected.to permit_actions([:update]) }
  end
end
