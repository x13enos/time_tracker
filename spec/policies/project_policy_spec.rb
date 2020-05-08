require 'rails_helper'

describe ProjectPolicy do
  let(:workspace) { create(:workspace)}

  context 'user is admin and defined project was passed' do
    let(:user) { build(:user, role: :admin, active_workspace: workspace) }
    let(:project) { create(:project) }

    before do
      project.users << user
    end

    subject { described_class.new(user, project) }

    it { is_expected.to permit_actions([:update, :destroy, :assign_user, :remove_user]) }
  end

  context 'user is admin and class was passed' do
    let(:user) { build(:user, role: :admin, active_workspace: workspace) }

    subject { described_class.new(user, Project) }

    it { is_expected.to permit_actions([:index, :create]) }
  end

  context 'user is staff and defined project was passed' do
    let(:user) { build(:user, role: :staff, active_workspace: workspace) }
    let(:project) { create(:project) }

    before do
      project.users << user
    end

    subject { described_class.new(user, project) }

    it { is_expected.to forbid_actions([:update, :destroy, :assign_user, :remove_user]) }
  end

  context 'user is staff and class was passed' do
    let(:user) { build(:user, role: :staff, active_workspace: workspace) }

    subject { described_class.new(user, Project) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'user was not found and class was passed' do
    let(:user) { build(:user, role: :staff, active_workspace: workspace) }
    let(:project) { create(:project) }

    before do
      project.users << user
    end

    subject { described_class.new(nil, project) }

    it { is_expected.to forbid_actions([:update, :destroy, :assign_user, :remove_user]) }
  end

  context 'user was not found and class was passed' do
    let(:user) { build(:user, role: :staff, active_workspace: workspace) }

    subject { described_class.new(nil, Project) }

    it { is_expected.to forbid_actions([:index, :create]) }
  end
end
