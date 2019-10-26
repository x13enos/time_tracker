require 'rails_helper'

describe ProjectPolicy do

  context "user is admin" do
    let(:user) { build(:user, role: :admin) }

    subject { described_class.new(user, 'project') }

    it { is_expected.to permit_actions(
      [:create, :create, :delete, :assign_user, :single, :all]
    ) }
  end

  context 'user is staff' do
    let(:user) { build(:user, role: :staff) }

    subject { described_class.new(user, 'project') }

    it { is_expected.to permit_action(:all) }
    it { is_expected.to forbid_actions(
      [:create, :create, :delete, :assign_user, :single]
    ) }
  end
end
