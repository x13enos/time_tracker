require 'rails_helper'

describe AuthPolicy do

  context 'user is staff' do
    let(:user) { build(:user, role: :staff) }

    subject { described_class.new(user, :auth) }

    it { is_expected.to permit_action(:destroy) }
  end

  context 'user was not found' do
    subject { described_class.new(nil, :auth) }

    it { is_expected.to forbid_action(:destroy) }
  end
end
