require 'rails_helper'

describe ProjectUserPolicy do

  context "user is owner" do
    let!(:workspace) { create(:workspace) }
    let!(:user) { create(:user, active_workspace: workspace) }
    let!(:project) { create(:project, workspace: workspace, users: [user]) }
    before do
      user.users_workspaces.find_by(workspace_id: workspace.id).update(role: "owner")
    end


    subject { described_class.new(user, project) }
    it { is_expected.to permit_actions([:create, :destroy]) }
  end

  context "user is admin" do
    let!(:workspace) { create(:workspace) }
    let!(:user) { create(:user, active_workspace: workspace) }
    let!(:project) { create(:project, workspace: workspace, users: [user]) }
    before do
      user.users_workspaces.find_by(workspace_id: workspace.id).update(role: "admin")
    end


    subject { described_class.new(user, project) }
    it { is_expected.to permit_actions([:create, :destroy]) }
  end

  context "user is staff" do
    let!(:workspace) { create(:workspace) }
    let!(:user) { create(:user, active_workspace: workspace) }
    let!(:project) { create(:project, workspace: workspace, users: [user]) }

    before do
      user.users_workspaces.find_by(workspace_id: workspace.id).update(role: "staff")
    end

    subject { described_class.new(user, workspace) }
    it { is_expected.to forbid_actions([:create, :destroy]) }
  end

end
