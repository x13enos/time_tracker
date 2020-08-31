require 'rails_helper'

RSpec.describe Users::ChangeWorkspaceForm, type: :model do
  let!(:workspace) { create(:workspace) }
  let!(:workspace_2) { create(:workspace) }
  let!(:user) { create(:user, active_workspace_id: workspace.id) }

  describe "persist!" do
    it "should update user's active workspace id" do
      user.workspaces << workspace_2
      form = Users::ChangeWorkspaceForm.new(workspace_2.id, user)
      form.persist!
      expect(form.user.reload.active_workspace_id).to eq(workspace_2.id)
    end
  end

end
