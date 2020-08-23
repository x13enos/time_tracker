require 'rails_helper'

RSpec.describe User, type: :model do

  context 'validations' do
    subject { build(:user, password: nil) }

    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:active_workspace_id) }
    it { should validate_uniqueness_of(:email) }
    it { should allow_value('user@gmail.com').for(:email) }
    it { should_not allow_value('usergmail.com').for(:email) }
    it { should validate_length_of(:password).is_at_least(8).is_at_most(32) }
    it { should validate_presence_of(:locale) }
    it { should validate_inclusion_of(:locale).in_array(User::SUPPORTED_LANGUAGES) }

    describe "active_workspace_is_one_of_users_workspaces" do
      let!(:active_workspace) { create(:workspace) }
      let(:user) { build(:user, active_workspace: active_workspace) }
      it "should add error if active workspace is not in list of user's workspaces" do
        user.save
        expect(user.errors[:active_workspace_id]).to include(I18n.t("users.errors.active_workspace_is_invalid"))
      end
    end
  end

  context 'associations' do
    subject { build(:user, password: nil) }

    it { should have_one(:notification_settings) }
    it { should have_and_belong_to_many(:projects) }
    it { should have_many(:users_workspaces) }
    it { should have_many(:workspaces).through(:users_workspaces) }
    it { should have_many(:time_records).dependent(:destroy) }
    it { should belong_to(:active_workspace).class_name("Workspace").with_foreign_key(:active_workspace_id) }
  end

  describe "#role" do
    it "should return role for active workspace if workspace_id wasn't passed" do
      user = create(:user, :admin)
      expect(user.role).to eq("admin")
    end

    it "should return role for passed workspace" do
      user = create(:user, :admin)
      workspace = create(:workspace, users: [user])
      user.users_workspaces.find_by(workspace_id: workspace.id).update(role: :owner)
      expect(user.role(workspace.id)).to eq("owner")
    end
  end

  describe "#admin?" do
    it "should return true if user's active role is admin" do
      user = create(:user, :admin)
      expect(user.admin?).to be_truthy
    end

    it "should return false if user's active role is not admin" do
      user = create(:user, :owner)
      expect(user.admin?).to be_falsey
    end
  end

  describe "#owner?" do
    it "should return true if user's active role is owner" do
      user = create(:user, :owner)
      expect(user.owner?).to be_truthy
    end

    it "should return false if user's active role is not owner" do
      user = create(:user, :admin)
      expect(user.owner?).to be_falsey
    end
  end

  describe "#workspace_owner?" do
    it "should return true if user is owner for passed workspace" do
      user = create(:user, :admin)
      workspace = create(:workspace, users: [user])
      user.users_workspaces.find_by(workspace_id: workspace.id).update(role: :owner)
      expect(user.workspace_owner?(workspace.id)).to be_truthy
    end

    it "should return false if user isn't owner for passed workspace" do
      user = create(:user, :owner)
      workspace = create(:workspace, users: [user])
      user.users_workspaces.find_by(workspace_id: workspace.id).update(role: :admin)
      expect(user.workspace_owner?(workspace.id)).to be_falsey
    end
  end

end
