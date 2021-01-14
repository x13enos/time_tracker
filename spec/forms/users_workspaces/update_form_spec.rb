require 'rails_helper'

RSpec.describe UsersWorkspaces::UpdateForm, type: :model do
  let!(:workspace) { create(:workspace) }
  let!(:user) { create(:user, :staff, active_workspace_id: workspace.id) }

  context 'validations' do

    subject { user_form }

    describe 'user_is_not_owner?' do
      it "should add error if user is owner for passed workspace" do
        user.workspace_settings(workspace.id).update(role: 'owner')
        users_workspaces_form = UsersWorkspaces::UpdateForm.new({ role: 'staff' }, user, workspace)
        users_workspaces_form.valid?
        expect(users_workspaces_form.errors.messages[:role]).to include(I18n.t("users.errors.can_not_change_role_for_owner"))
      end

      it "should not add error if user is not owner for passed workspace" do
        users_workspaces_form = UsersWorkspaces::UpdateForm.new({ role: 'staff' }, user, workspace)
        users_workspaces_form.valid?
        expect(users_workspaces_form.errors.messages[:role]).to_not include(I18n.t("users.errors.can_not_change_role_for_owner"))
      end
    end

    describe 'role_inclusion?' do
      let(:users_workspaces_form) { UsersWorkspaces::UpdateForm.new({ role: 'staff' }, user, workspace) }

      it "should add error if passed role isn't included to the list of roles" do
        users_workspaces_form = UsersWorkspaces::UpdateForm.new({ role: 'owner' }, user, workspace)
        users_workspaces_form.valid?
        expect(users_workspaces_form.errors.messages[:role]).to_not include(I18n.t("activemodel.errors.models.attributes.role.inclusion"))
      end

      it "should not add error if user is not owner for passed workspace" do
        users_workspaces_form = UsersWorkspaces::UpdateForm.new({ role: 'staff' }, user, workspace)
        users_workspaces_form.valid?
        expect(users_workspaces_form.errors.messages[:role]).to_not include(I18n.t("activemodel.errors.models.attributes.role.inclusion"))
      end
    end
  end

  describe "persist!" do
    it "should update user's role for passed workspace" do
      users_workspaces_form = UsersWorkspaces::UpdateForm.new({ role: 'admin' }, user, workspace)
      users_workspaces_form.persist!
      expect(user.workspace_settings.role).to eq("admin")
    end
  end

end
