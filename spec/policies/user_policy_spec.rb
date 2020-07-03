require 'rails_helper'

describe UserPolicy do

  context "user is admin" do
    let(:user) { build(:user, role: :admin) }

    subject { described_class.new(user, User) }

    it { is_expected.to permit_actions([:index, :update]) }
  end

  context 'user is staff' do
    let(:user) { build(:user, role: :staff) }

    subject { described_class.new(user, 'user') }

    it { is_expected.to forbid_actions([:index]) }
    it { is_expected.to permit_action(:update) }
  end
end
