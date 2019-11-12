require 'rails_helper'

describe UserPolicy do

  context "user is admin" do
    let(:user) { build(:user, role: :admin) }

    subject { described_class.new(user, 'user') }

    it { is_expected.to permit_actions([:sign_up, :sign_out]) }
  end

  context 'user is staff' do
    let(:user) { build(:user, role: :staff) }

    subject { described_class.new(user, 'user') }

    it { is_expected.to forbid_action(:sign_up) }
    it { is_expected.to permit_action(:sign_out) }
  end
end
