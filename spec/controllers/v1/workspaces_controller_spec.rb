require 'rails_helper'

RSpec.describe V1::WorkspacesController, type: :controller do

  describe "GET #index" do
    context "user is admin" do
      login_admin

      let!(:workspace1) { create(:workspace, user_ids: [@current_user.id]) }
      let!(:workspace2) { create(:workspace) }


      it "should return list of user workspaces with user_ids" do
        controller.instance_variable_set(:@current_user, @current_user)
        get :index, params: { format: :json }
        expect(response.body).to include([
          {
            id: workspace1.id,
            name: workspace1.name,
            user_ids: [@current_user.id]
          }
        ].to_json)
      end
    end

    context "user is staff" do
      login_staff

      let!(:workspace1) { create(:workspace, user_ids: [@current_user.id]) }
      let!(:workspace2) { create(:workspace) }


      it "should return list of user workspaces w/o user_ids" do
        controller.instance_variable_set(:@current_user, @current_user)
        get :index, params: { format: :json }
        expect(response.body).to include([
          {
            id: workspace1.id,
            name: workspace1.name
          }
        ].to_json)
      end
    end
  end

  describe "POST #create" do
    login_admin

    it "should return workspace's data if it was created" do
      post :create, params: { name: "test-workspace", format: :json }
      expect(response.body).to eq({
        id: Workspace.last.id,
        name: "test-workspace",
        user_ids: [@current_user.id]
      }.to_json)
    end

    it "should create workspace and add current user to that" do
      post :create, params: { name: "test-workspace", format: :json }
      expect(Workspace.last.user_ids).to eq([@current_user.id])
    end

    it "should return error message if workspace wasn't created" do
      post :create, params: { name: "", format: :json }
      expect(response.body).to eq({ error: "can't be blank" }.to_json)
    end
  end

  describe "PUT #update" do
    login_admin
    let!(:workspace) { create(:workspace) }

    before do
      workspace.users << @current_user
    end

    it "should return workspace's data if workspace was updated" do
      put :update, params: { id: workspace.id, name: "test-workspace", format: :json }
      expect(response.body).to eq({
        id: workspace.id,
        name: "test-workspace",
        user_ids: workspace.user_ids
      }.to_json)
    end

    it "should return error message if workspace wasn't updated" do
      put :update, params: { id: workspace.id, name: "", format: :json }
      expect(response.body).to eq({ error: "can't be blank" }.to_json)
    end
  end

  describe "DELETE #destroy" do
    login_admin
    let!(:workspace) { create(:workspace) }

    before do
      workspace.users << @current_user
    end

    it "should return workspace's data if it was deleted" do
      delete :destroy, params: { id: workspace.id, format: :json }
      expect(response.body).to eq({
        id: workspace.id,
        name: workspace.name,
        user_ids: []
      }.to_json)
    end

    it "should remove workspace" do
      expect { delete :destroy, params: { id: workspace.id, format: :json } }.to change { Workspace.count }.from(2).to(1)
    end

    it "should return error message if workspace wasn't deleted" do
      allow(@current_user).to receive_message_chain(:workspaces, :find) { workspace }
      allow(workspace).to receive(:destroy) { false }
      workspace.errors.add(:base, "can't delete")
      delete :destroy, params: { id: workspace.id, format: :json }
      expect(response.body).to eq({ error: "can't delete" }.to_json)
    end
  end
end
