require 'rails_helper'

describe WorkspacePolicy do

  context "user is admin" do
    let(:active_workspace) { create(:workspace) }
    let(:user) { build(:user, role: :admin, workspace_ids: [active_workspace.id], active_workspace: active_workspace) }

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

      it { is_expected.to permit_actions([:update, :destroy]) }
    end
  end

  context "user is staff" do
    let(:workspace) { create(:workspace) }
    let(:user) { build(:user, active_workspace_id: workspace.id) }

    subject { described_class.new(user, workspace) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_actions([:create, :update, :destroy]) }

  end

end
