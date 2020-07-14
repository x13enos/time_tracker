require 'rails_helper'

describe ProjectUserPolicy do

  context "user is admin" do
    let!(:workspace) { create(:workspace) }
    let!(:user) { create(:user, role: :admin, workspace_ids: [workspace.id], active_workspace: workspace) }

    subject { described_class.new(user, workspace) }
    it { is_expected.to permit_actions([:create, :destroy]) }
  end

  context "user is staff" do
    let(:workspace) { create(:workspace) }
    let(:user) { create(:user, role: :staff) }

    before do
      workspace.users << user
    end

    subject { described_class.new(user, workspace) }
    it { is_expected.to forbid_actions([:create, :destroy]) }
  end

end
