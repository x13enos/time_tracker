require 'rails_helper'

RSpec.describe User, type: :model do

  context 'associations' do
    subject { build(:user, password: nil) }

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

  describe "#notification_settings" do
    it "should return notification_settings for active workspace if workspace_id wasn't passed" do
      user = create(:user, :admin)
      user.workspace_settings.update(notification_rules: ["email_assign_user_to_project"])
      expect(user.notification_settings).to eq(["email_assign_user_to_project"])
    end

    it "should return notification_settings for passed workspace" do
      user = create(:user, :admin)
      workspace = create(:workspace, users: [user])
      user.workspace_settings(workspace.id).update(notification_rules: ["telegram_assign_user_to_project"])
      expect(user.notification_settings(workspace.id)).to eq(["telegram_assign_user_to_project"])
    end
  end

  describe "#workspace_settings" do
    it "should return users_workspace for active workspace if workspace_id wasn't passed" do
      user = create(:user, :admin)
      expect(user.workspace_settings.workspace_id).to eq(user.active_workspace_id)
    end

    it "should return users_workspace for passed workspace" do
      user = create(:user, :admin)
      workspace = create(:workspace, users: [user])
      expect(user.workspace_settings(workspace.id).workspace_id).to eq(workspace.id)
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
