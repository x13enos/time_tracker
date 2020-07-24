require 'rails_helper'

RSpec.describe V1::ProjectsController, type: :controller do
  login_staff

  describe "GET #index" do
    it "should return list of user's projects" do

      project = create(:project, name: "company A", workspace: @current_user.active_workspace)
      project_2 = create(:project, name: "company B", workspace: @current_user.active_workspace)
      project_3 = create(:project, name: "company C", workspace: @current_user.active_workspace)

      project.users << @current_user
      project_2.users << @current_user

      get :index, params: { format: :json }
      expect(response.body).to eq([
        {
          id: project.id,
          name: project.name,
          user_ids: [@current_user.id],
          regexp_of_grouping: nil
        },
        {
          id: project_2.id,
          name: project_2.name,
          user_ids: [@current_user.id],
          regexp_of_grouping: nil
        }
      ].to_json)
    end

    it "should set locale if user was authorized" do
      @current_user.update(locale: "ru")
      expect(I18n).to receive(:with_locale).with("ru")
      get :index, params: { format: :json }
    end
  end

  describe "POST #create" do
    login_admin

    it "should return project's data if it was created" do
      post :create, params: { name: "test-project", format: :json }
      expect(response.body).to eq({
        id: Project.last.id,
        name: "test-project",
        user_ids: [@current_user.id],
        regexp_of_grouping: nil
      }.to_json)
    end

    it "should create project and add active workspace to that" do
      post :create, params: { name: "test-project", format: :json }
      expect(Project.last.workspace_id).to eq(@current_user.active_workspace_id)
    end

    it "should return error message if project wasn't created" do
      post :create, params: { name: "", format: :json }
      expect(response.body).to eq({ errors: { name: ["can't be blank"] } }.to_json)
    end
  end

  describe "PUT #update" do
    login_admin
    let!(:project) { create(:project, workspace: @current_user.active_workspace) }

    before do
      project.users << @current_user
    end

    it "should return project's data if project was updated" do
      put :update, params: { id: project.id, name: "test-project", format: :json }
      expect(response.body).to eq({
        id: project.id,
        name: "test-project",
        user_ids: project.user_ids,
        regexp_of_grouping: nil
      }.to_json)
    end

    it "should return error message if project wasn't updated" do
      put :update, params: { id: project.id, name: "", format: :json }
      expect(response.body).to eq({ errors: { name: ["can't be blank"] } }.to_json)
    end
  end

  describe "DELETE #destroy" do
    login_admin
    let!(:project) { create(:project, workspace: @current_user.active_workspace) }

    before do
      project.users << @current_user
    end

    it "should return project's data if it was deleted" do
      delete :destroy, params: { id: project.id, format: :json }
      expect(response.body).to eq({
        id: project.id,
        name: project.name,
        user_ids: [],
        regexp_of_grouping: nil
      }.to_json)
    end

    it "should remove project" do
      expect { delete :destroy, params: { id: project.id, format: :json } }.to change { Project.count }.from(1).to(0)
    end

    it "should return error message if project wasn't deleted" do
      allow(@current_user).to receive_message_chain(:projects, :by_workspace, :find) { project }
      allow(project).to receive(:destroy) { false }
      project.errors.add(:base, "can't delete")
      delete :destroy, params: { id: project.id, format: :json }
      expect(response.body).to eq({ errors: { base: ["can't delete"] } }.to_json)
    end
  end

end
