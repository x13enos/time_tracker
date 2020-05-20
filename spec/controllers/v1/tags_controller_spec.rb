require 'rails_helper'

RSpec.describe V1::TagsController, type: :controller do
  login_staff

  describe "GET #index" do
    it "should return list of workspace's tags" do

      tag = create(:tag, name: "tag A", workspace: @current_user.active_workspace)
      tag_2 = create(:tag, name: "tag B", workspace: @current_user.active_workspace)
      tag_3 = create(:tag, name: "tag C")

      get :index, params: { format: :json }
      expect(response.body).to eq([
        {
          id: tag.id,
          name: tag.name
        },
        {
          id: tag_2.id,
          name: tag_2.name,
        }
      ].to_json)
    end
  end

  describe "POST #create" do
    login_admin

    it "should return tag's data if it was created" do
      post :create, params: { name: "test-tag", format: :json }
      expect(response.body).to eq({
        id: Tag.last.id,
        name: "test-tag"
      }.to_json)
    end

    it "should create tag and add active workspace to that" do
      post :create, params: { name: "test-tag", format: :json }
      expect(Tag.last.workspace_id).to eq(@current_user.active_workspace_id)
    end

    it "should return error message if tag wasn't created" do
      post :create, params: { name: "", format: :json }
      expect(response.body).to eq({ errors: { name: ["can't be blank"] } }.to_json)
    end
  end

  describe "PUT #update" do
    login_admin
    let!(:tag) { create(:tag, workspace: @current_user.active_workspace) }

    it "should return tag's data if tag was updated" do
      put :update, params: { id: tag.id, name: "test-tag", format: :json }
      expect(response.body).to eq({
        id: tag.id,
        name: "test-tag"
      }.to_json)
    end

    it "should return error message if tag wasn't updated" do
      put :update, params: { id: tag.id, name: "", format: :json }
      expect(response.body).to eq({ errors: { name: ["can't be blank"] } }.to_json)
    end
  end

  describe "DELETE #destroy" do
    login_admin
    let!(:tag) { create(:tag, workspace: @current_user.active_workspace) }

    it "should return tag's data if it was deleted" do
      delete :destroy, params: { id: tag.id, format: :json }
      expect(response.body).to eq({
        id: tag.id,
        name: tag.name
      }.to_json)
    end

    it "should remove tag" do
      expect { delete :destroy, params: { id: tag.id, format: :json } }.to change { Tag.count }.from(1).to(0)
    end

    it "should return error message if tag wasn't deleted" do
      allow(Tag).to receive_message_chain(:by_workspace, :find) { tag }
      allow(tag).to receive(:destroy) { false }
      tag.errors.add(:base, "can't delete")
      delete :destroy, params: { id: tag.id, format: :json }
      expect(response.body).to eq({ errors: { base: ["can't delete"] } }.to_json)
    end
  end

end
