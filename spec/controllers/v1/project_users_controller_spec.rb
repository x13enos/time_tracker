require 'rails_helper'

RSpec.describe V1::ProjectUsersController, type: :controller do
  def user_info(user)
    {
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      locale: user.locale,
      active_workspace_id: user.active_workspace_id,
      notification_settings: user.notification_settings.rules
    }
  end

  describe "POST #create" do
    login_user(:admin)
    let!(:project) { create(:project, workspace: @current_user.active_workspace) }
    let!(:user) { create(:user, workspace_ids: [@current_user.active_workspace.id], active_workspace: @current_user.active_workspace) }

    before do
      project.users << @current_user
    end

    context "user was assigned to project" do

      it "should assigning user to the passed project" do
        post :create, params: { project_id: project.id, user_id: user.id, format: :json }
        expect(project.reload.user_ids).to include(user.id)
      end

      it "should return success status" do
        post :create, params: { project_id: project.id, user_id: user.id, format: :json }
        expect(response.body).to eq(user_info(user).to_json)
      end

      it "should create notification service" do
        expect(UserNotifier).to receive(:new).with(user, :assign_user_to_project, { project: project }) { double(perform: true) }
        post :create, params: { project_id: project.id, user_id: user.id, format: :json }
      end

      it "should launch notification service" do
        notifier = double
        allow(UserNotifier).to receive(:new) { notifier }
        expect(notifier).to receive(:perform)
        post :create, params: { project_id: project.id, user_id: user.id, format: :json }
      end

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
    login_user(:admin)
    let!(:project) { create(:project, workspace: @current_user.active_workspace) }
    let!(:user) { create(:user, workspace_ids: [@current_user.active_workspace.id], active_workspace: @current_user.active_workspace) }

    before do
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
