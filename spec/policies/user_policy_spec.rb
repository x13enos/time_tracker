require 'rails_helper'

describe UserPolicy do

  context "user is owner" do
    let(:user) { create(:user, :owner) }

    subject { described_class.new(user, User) }

    it { is_expected.to permit_actions([:index, :update, :change_workspace]) }
  end

  context "user is admin" do
    let(:user) { create(:user, :admin) }

    subject { described_class.new(user, User) }

    it { is_expected.to permit_actions([:index, :update, :change_workspace]) }
  end

  context 'user is staff' do
    let(:user) { create(:user, :staff) }

    subject { described_class.new(user, 'user') }

    it { is_expected.to forbid_actions([:index]) }
    it { is_expected.to permit_actions([:update, :change_workspace]) }
  end
end
