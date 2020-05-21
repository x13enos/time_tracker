require 'rails_helper'

describe TagPolicy do

  context "only action index should be allow for staff user" do
    let(:user) { build(:user) }

    subject { described_class.new(user, Tag) }

    it { is_expected.to permit_actions([:index]) }
    it { is_expected.to forbid_actions([:create, :update, :destroy])}
  end

  context 'admin can do all actions' do
    let(:admin) { build(:user, :admin) }

    let(:tag) { create(:tag) }

    subject { described_class.new(admin, tag) }

    it { is_expected.to permit_actions([:index, :create, :update, :destroy]) }
  end
end
