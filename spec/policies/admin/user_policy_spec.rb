require 'rails_helper'

module Admin

  describe UserPolicy do

    context "user is owner" do
      let(:user) { create(:user, :owner) }

      subject { described_class.new(user, :user) }

      it { is_expected.to permit_actions([:index, :update]) }
    end

    context "user is admin" do
      let(:user) { create(:user, :admin) }

      subject { described_class.new(user, :user) }

      it { is_expected.to permit_actions([:index, :update]) }
    end

    context 'user is staff' do
      let(:user) { create(:user, :staff) }

      subject { described_class.new(user, :user) }

      it { is_expected.to forbid_actions([:index, :update]) }
    end
  end

end
