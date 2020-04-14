require 'rails_helper'

describe UserPolicy do

  context "user is admin" do
    let(:user) { build(:user, role: :admin) }

    subject { described_class.new(user, User) }

    it { is_expected.to permit_actions([:index, :create, :update, :destroy]) }
  end

  context 'user is staff' do
    let(:user) { build(:user, role: :staff) }

    subject { described_class.new(user, 'user') }

    it { is_expected.to forbid_actions([:create, :index, :destroy]) }
    it { is_expected.to permit_action(:update) }
  end
end
