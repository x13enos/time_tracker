require 'rails_helper'

RSpec.describe V1::UsersController, type: :controller do

  def user_info(user)
    {
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      locale: user.locale,
      active_workspace_id: user.active_workspace_id,
      notification_settings: user.notification_settings,
      workspaces: [
        { id: user.workspaces.first.id, name: user.workspaces.first.name }
      ]
    }
  end

  describe "GET #index" do
    login_user(:admin)

    it "should return list of users for current workspace" do
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
      user_1 = create(:user, active_workspace: @current_user.active_workspace)
      user_2 = create(:user)
      get :index, params: { current_workspace: false, format: :json }
      expect(response.body).to eql([
        {
          id: @current_user.id,
          name: @current_user.name,
          email: @current_user.email
        },
        {
          id: user_1.id,
          name: user_1.name,
          email: user_1.email
        }
      ].to_json)
    end
  end

  describe "PUT #update" do
    login_user(:staff)

    it "should return user's data if user info was updated" do
      form = double(save: true, user: @current_user)
      allow(Users::UpdateForm).to receive(:new) { form }
      put :update, params: { email: "example@gmail.com", format: :json }
      expect(response.body).to eq(user_info(form.user.reload).to_json)
    end

    it "should return error message if user info was not updated" do
      form = double(save: false, user: @current_user, errors: { email: [] })
      allow(Users::UpdateForm).to receive(:new) { form }
      put :update, params: { email: "",  format: :json }
      expect(response.body).to eq({ errors: form.errors }.to_json)
    end
  end

  describe "PUT #change_workspace" do
    login_user(:staff)

    it "should return status 200 if user's active workspace id was changed" do
      form = double(save: true, user: @current_user)
      allow(Users::ChangeWorkspaceForm).to receive(:new).with("15", @current_user) { form }
      put :change_workspace, params: { workspace_id: "15", format: :json }
      expect(response.status).to eq(200)
    end

    it "should return error message if user info was not updated" do
      form = double(save: false, user: @current_user, errors: { active_workspace_id: [] })
      allow(Users::ChangeWorkspaceForm).to receive(:new) { form }
      put :change_workspace, params: { workspace_id: "",  format: :json }
      expect(response.body).to eq({ errors: form.errors }.to_json)
    end
  end
end
