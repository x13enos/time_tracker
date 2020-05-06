require 'rails_helper'

describe WorkspacePolicy do

  context "user is admin" do
    let(:user) { build(:user, role: :admin) }

    context "actions 'create' and 'index' doesn't require any conditions" do

      subject { described_class.new(user, TimeRecord) }

      it { is_expected.to permit_actions([:index, :create]) }
    end

    context 'record belongs to user' do
      let(:workspace) { create(:workspace) }

      before do
        workspace.users << user
      end

      subject { described_class.new(user, workspace) }

      it { is_expected.to permit_actions([:update, :destroy, :invite_user, :remove_user]) }
    end
  end

  context "user is staff" do
    let(:user) { build(:user) }
    let(:workspace) { create(:workspace) }

    subject { described_class.new(user, workspace) }

    context "actions should be forbidden" do
      it { is_expected.to forbid_actions([:index, :create, :update, :destroy, :invite_user, :remove_user]) }
    end

  end

end
