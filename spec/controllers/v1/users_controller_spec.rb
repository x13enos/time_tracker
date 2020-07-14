require 'rails_helper'

RSpec.describe V1::UsersController, type: :controller do

  def user_info(user)
    {
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      locale: user.locale,
      active_workspace_id: user.active_workspace_id
    }
  end

  describe "GET #index" do
    login_admin

    it "should return list of users for current workspace" do
      Workspace.last.users << @current_user
      get :index, params: { current_workspace: true, format: :json }
      expect(response.body).to eq([
        {
          id: @current_user.id,
          name: @current_user.name,
          email: @current_user.email
        }
      ].to_json)
    end

    it "should return list of users for admin's workspaces" do
      workspace = create(:workspace)
      another_user = create(:user, workspace_ids: [workspace.id], active_workspace: workspace)
      workspace.users << @current_user
      @current_user.reload
      get :index, params: { current_workspace: false, format: :json }
      expect(response.body).to eql([
        {
          id: @current_user.id,
          name: @current_user.name,
          email: @current_user.email
        },
        {
          id: another_user.id,
          name: another_user.name,
          email: another_user.email
        }
      ].to_json)
    end
  end

  describe "PUT #update" do
    login_staff

    it "should return user's data if user info was updated" do
      put :update, params: { email: "example@gmail.com", format: :json }
      expect(response.body).to eq(user_info(@current_user).to_json)

    end

    it "should return error message if user info was not updated" do
      put :update, params: { email: "",  format: :json }
      expect(response.body).to eq({ errors: @current_user.errors }.to_json)
    end
  end
end
