require 'rails_helper'

describe WorkspaceUserPolicy do

  context "user is owner" do
    let!(:workspace) { create(:workspace) }
    let!(:user) { create(:user, :owner, active_workspace: workspace) }

    subject { described_class.new(user, workspace) }
    it { is_expected.to permit_actions([:create, :destroy]) }
  end

  context "user is admin" do
    let!(:workspace) { create(:workspace) }
    let!(:user) { create(:user, :admin, active_workspace: workspace) }

    subject { described_class.new(user, workspace) }
    it { is_expected.to forbid_actions([:create, :destroy]) }
  end

  context "user is staff" do
    let!(:workspace) { create(:workspace) }
    let!(:user) { create(:user, :staff, active_workspace: workspace) }

    subject { described_class.new(user, workspace) }
    it { is_expected.to forbid_actions([:create, :destroy]) }
  end

end
