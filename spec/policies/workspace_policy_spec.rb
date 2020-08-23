require 'rails_helper'

describe WorkspacePolicy do

  context "user is owner" do
    let(:active_workspace) { create(:workspace) }
    let(:user) { create(:user, active_workspace: active_workspace) }
    before do
      user.users_workspaces.find_by(workspace_id: active_workspace.id).update(role: "owner")
    end

    context "actions 'create' and 'index' doesn't require any conditions" do

      subject { described_class.new(user, TimeRecord) }

      it { is_expected.to permit_actions([:index, :create]) }
    end

    context 'record belongs to user' do
      let(:workspace) { create(:workspace) }

      before do
        workspace.users << user
        user.users_workspaces.find_by(workspace_id: workspace.id).update(role: "owner")
      end

      subject { described_class.new(user, workspace) }

      it { is_expected.to permit_actions([:update, :destroy]) }
    end
  end

  context "user is staff" do
    let(:workspace) { create(:workspace) }
    let(:user) { create(:user, active_workspace_id: workspace.id) }

    subject { described_class.new(user, workspace) }

    before do
      user.users_workspaces.find_by(workspace_id: workspace.id).update(role: "staff")
    end

    it { is_expected.to permit_actions([:index, :create]) }
    it { is_expected.to forbid_actions([:update, :destroy]) }

  end

end
