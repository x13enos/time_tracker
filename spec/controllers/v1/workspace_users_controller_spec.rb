require 'rails_helper'

RSpec.describe V1::WorkspaceUsersController, type: :controller do
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
    let!(:workspace) { create(:workspace) }

    before do
      workspace.users << @current_user
    end

    context "user already was created" do
      let!(:user) { create(:user) }

      it "should build service for assigning user" do
        expect(AssignUserService).to receive(:new)
          .with(user.email, @current_user, workspace) { double(perform: user) }
        post :create, params: { workspace_id: workspace.id, email: user.email, format: :json }
      end

      it "should launch service for assigning user" do
        service = double
        allow(AssignUserService).to receive(:new)
          .with(user.email, @current_user, workspace) { service }
        expect(service).to receive(:perform)
        post :create, params: { workspace_id: workspace.id, email: user.email, format: :json }
      end

      it "should return success status if service of assigning returns user" do
        allow(AssignUserService).to receive_message_chain(:new, :perform) { user }
        post :create, params: { workspace_id: workspace.id, email: user.email, format: :json }
        expect(response.body).to eq(user_info(user).to_json)
      end

      it "should return error message if user wasn't assigned to the project" do
        allow(AssignUserService).to receive_message_chain(:new, :perform).and_raise(ActiveRecord::StaleObjectError)
        post :create, params: { workspace_id: workspace.id, email: user.email, format: :json }
        expect(response.body).to eq({ error: I18n.t("workspaces.errors.user_was_not_invited") }.to_json)
      end
    end
  end

  describe "DELETE #destroy" do
    login_admin
    let!(:workspace) { create(:workspace) }
    let(:user) { create(:user) }

    before do
      workspace.users << [@current_user, user]
    end

    it "should return success status if user was removed from project" do
      delete :destroy, params: { workspace_id: workspace.id, id: user.id, format: :json }
      expect(response.body).to eq({ success: true }.to_json)
    end

    it "should remove user from list of workspace's users" do
      delete :destroy, params: { workspace_id: workspace.id, id: user.id, format: :json }
      expect(workspace.reload.user_ids).to_not include(user.id)
    end

    it "should return error message if user wasn't removed from project" do
      allow(@current_user).to receive_message_chain(:workspaces, :find) { workspace }
      allow(workspace).to receive_message_chain(:users, :delete).and_raise(ActiveRecord::StaleObjectError)
      delete :destroy, params: { workspace_id: workspace.id, id: user.id, format: :json }
      expect(response.body).to eq({ error: I18n.t("workspaces.errors.user_was_not_removed") }.to_json)
    end
  end
end
