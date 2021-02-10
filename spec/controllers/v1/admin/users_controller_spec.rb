require 'rails_helper'

RSpec.describe V1::Admin::UsersController, type: :controller do

  describe "GET #index" do
    it "should return list of users" do

      workspace = create(:workspace)
      workspace_2 = create(:workspace)

      login_user_with_workspace(:admin, workspace)
      user = create(:user, active_workspace: workspace_2, workspaces: [workspace_2])
      user_2 = create(:user, active_workspace: workspace_2, workspaces: [workspace, workspace_2])

      get :index, params: { format: :json }
      expect(response.body).to eq([
        {
          id: @current_user.id,
          name: @current_user.name,
          email: @current_user.email,
          role: @current_user.role(workspace)
        },
        {
          id: user_2.id,
          name: user_2.name,
          email: user_2.email,
          role: user_2.role(workspace)
        },
      ].to_json)
    end
  end

  describe "PUT #update" do
    login_user(:admin)
    let!(:user) { create(:user, :staff, active_workspace: @current_user.active_workspace) }

    it "should return user's data if user info was updated" do
      form = double(save: true)
      allow(UsersWorkspaces::UpdateForm).to receive(:new) { form }
      put :update, params: { id: user.id, role: "admin", format: :json }
      expect(response.body).to eq(user_info_with_workspaces(user.reload).to_json)
    end

    it "should return error message if user info was not updated" do
      form = double(save: false, errors: { role: [] })
      allow(UsersWorkspaces::UpdateForm).to receive(:new) { form }
      put :update, params: { id: user.id, role: "owner", format: :json }
      expect(response.body).to eq({ errors: form.errors }.to_json)
    end
  end
end
