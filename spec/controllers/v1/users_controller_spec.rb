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
      notification_settings: user.notification_settings
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
      workspace = create(:workspace)
      another_user = create(:user, active_workspace: workspace)
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
end
