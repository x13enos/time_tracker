require 'rails_helper'

RSpec.describe V1::ProjectUsersController, type: :controller do
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

  describe "POST #create" do
    login_admin
    let!(:project) { create(:project, workspace: @current_user.active_workspace) }
    let!(:user) { create(:user, active_workspace: @current_user.active_workspace) }

    before do
      @current_user.active_workspace.users << [@current_user, user]
      project.users << @current_user
    end

    it "should assigning user to the passed project" do
      post :create, params: { project_id: project.id, user_id: user.id, format: :json }
      expect(project.reload.user_ids).to include(user.id)
    end

    it "should return success status if user was added to the project" do
      post :create, params: { project_id: project.id, user_id: user.id, format: :json }
      expect(response.body).to eq(user_info(user).to_json)
    end

    it "should return error message if user wasn't assigned to the project" do
      allow(@current_user).to receive_message_chain(:projects, :find) { project }
      allow(project).to receive(:users).and_raise("Error")
      post :create, params: { project_id: project.id, user_id: user.id, format: :json }
      expect(response.body).to eq({ error: I18n.t("projects.errors.user_was_not_invited") }.to_json)
    end

    it "shouldn't add user to the project if user doesn't belong to current workspace" do
      another_user = create(:user)
      post :create, params: { project_id: project.id, user_id: another_user.id, format: :json }
      expect(project.reload.user_ids).to_not include(user.id)
    end
  end

  describe "DELETE #destroy" do
    login_admin
    let!(:project) { create(:project, workspace: @current_user.active_workspace) }
    let(:user) { create(:user, active_workspace: @current_user.active_workspace) }

    before do
      @current_user.active_workspace.users << [@current_user, user]
      project.users << [@current_user, user]
    end

    it "should return success status if user was removed from project" do
      delete :destroy, params: { project_id: project.id, id: user.id, format: :json }
      expect(response.body).to eq({ success: true }.to_json)
    end

    it "should remove user from list of project's users" do
      delete :destroy, params: { project_id: project.id, id: user.id, format: :json }
      expect(project.reload.user_ids).to_not include(user.id)
    end

    it "should return error message if user wasn't removed from project" do
      allow(@current_user).to receive_message_chain(:projects, :find) { project }
      allow(project).to receive_message_chain(:users, :delete).and_raise(ActiveRecord::StaleObjectError)
      delete :destroy, params: { project_id: project.id, id: user.id, format: :json }
      expect(response.body).to eq({ error: I18n.t("projects.errors.user_was_not_removed") }.to_json)
    end
  end
end
