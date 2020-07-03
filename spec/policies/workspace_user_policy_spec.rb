require 'rails_helper'

describe WorkspaceUserPolicy do

  context "user is admin" do
    let(:project) { create(:project) }
    let(:user) { create(:user, role: :admin) }

    before do
      project.users << user
    end

    subject { described_class.new(user, project) }
    it { is_expected.to permit_actions([:create, :destroy]) }
  end

  context "user is staff" do
    let(:project) { create(:project) }
    let(:user) { create(:user, role: :staff) }

    before do
      project.users << user
    end

    subject { described_class.new(user, project) }
    it { is_expected.to forbid_actions([:create, :destroy]) }
  end

end
