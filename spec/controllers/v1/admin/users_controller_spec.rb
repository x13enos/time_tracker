require 'rails_helper'

RSpec.describe V1::Admin::UsersController, type: :controller do

  describe "GET #index" do
    it "should return list of users" do

      workspace = create(:workspace)
      workspace_2 = create(:workspace)

      login_user(:admin, workspace)
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
end
