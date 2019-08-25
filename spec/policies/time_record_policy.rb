require 'rails_helper'

describe TimeRecordPolicy do

  context 'user was found' do
    subject { described_class.new(create(:user), :time_record) }

    it { is_expected.to permit_actions([:create]) }
  end

  context 'user was not found' do
    subject { described_class.new(nil, :time_record) }

    it { is_expected.to forbid_actions([:create]) }
  end
end
