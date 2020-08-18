require 'rails_helper'

describe ReportPolicy do

  context 'user is staff' do
    let(:user) { build(:user, :staff) }

    subject { described_class.new(user, :report) }

    it { is_expected.to permit_action(:index) }
  end

  context 'user was not found' do
    let(:user) { build(:user, :staff) }

    subject { described_class.new(nil, :report) }

    it { is_expected.to forbid_action(:index) }
  end
end
