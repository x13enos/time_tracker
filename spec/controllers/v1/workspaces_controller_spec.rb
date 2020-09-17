require 'rails_helper'

RSpec.describe V1::WorkspacesController, type: :controller do

  describe "GET #index" do
    context "user is admin" do
      let!(:workspace) { create(:workspace) }

      it "should return list of user workspaces with user_ids" do
        login_user(:owner, workspace)
        controller.instance_variable_set(:@current_user, @current_user)
        get :index, params: { format: :json }
        expect(response.body).to include([
          {
            id: @current_user.active_workspace.id,
            name: @current_user.active_workspace.name,
            owner: true
          }
        ].to_json)
      end
    end
  end

  describe "POST #create" do
    login_user(:staff)

    before do
      controller.instance_variable_set(:@current_user, @current_user)
    end

    it "should return workspace's data if it was created" do
      post :create, params: { name: "test-workspace", format: :json }
      expect(response.body).to eq({
        id: Workspace.last.id,
        name: "test-workspace",
        user_ids: [@current_user.id],
        owner: true
      }.to_json)
    end

    it "should create workspace and add current user to that" do
      post :create, params: { name: "test-workspace", format: :json }
      expect(Workspace.last.user_ids).to eq([@current_user.id])
    end

    it "should assign user as owner to new workspace" do
      post :create, params: { name: "test-workspace", format: :json }
      expect(@current_user.users_workspaces.last.owner?).to be_truthy
    end

    it "should return error message if workspace wasn't created" do
      post :create, params: { name: "", format: :json }
      expect(response.body).to eq({ errors: { name: ["can't be blank"] } }.to_json)
    end
  end

  describe "PUT #update" do
    let!(:workspace) { create(:workspace) }

    before do
      login_user(:owner, workspace)
      controller.instance_variable_set(:@current_user, @current_user)
    end

    it "should return workspace's data if workspace was updated" do
      put :update, params: { id: workspace.id, name: "test-workspace", format: :json }
      expect(response.body).to eq({
        id: workspace.id,
        name: "test-workspace",
        user_ids: workspace.user_ids,
        owner: true
      }.to_json)
    end

    it "should return error message if workspace wasn't updated" do
      put :update, params: { id: workspace.id, name: "", format: :json }
      expect(response.body).to eq({ errors: { name: ["can't be blank"] } }.to_json)
    end
  end

  describe "DELETE #destroy" do
    let!(:workspace) { create(:workspace) }

    before do
      login_user(:owner, workspace)
      controller.instance_variable_set(:@current_user, @current_user)
    end

    it "should return workspace's data if it was deleted" do
      delete :destroy, params: { id: workspace.id, format: :json }
      expect(response.body).to eq({
        id: workspace.id,
        name: workspace.name,
        user_ids: [@current_user.id],
        owner: true
      }.to_json)
    end

    it "should remove workspace" do
      expect { delete :destroy, params: { id: workspace.id, format: :json } }.to change { Workspace.count }.from(1).to(0)
    end

    it "should return error message if workspace wasn't deleted" do
      allow(@current_user).to receive_message_chain(:workspaces, :find) { workspace }
      allow(workspace).to receive(:destroy) { false }
      workspace.errors.add(:base, "can't delete")
      delete :destroy, params: { id: workspace.id, format: :json }
      expect(response.body).to eq({ errors: { base: ["can't delete"] } }.to_json)
    end
  end
end
