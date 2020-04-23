require 'rails_helper'

RSpec.describe V1::ProjectsController, type: :controller do
  login_staff

  describe "GET #index" do
    it "should return list of user's projects" do

      project = create(:project, name: "company A")
      project_2 = create(:project, name: "company B")
      project_3 = create(:project, name: "company C")

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
      get :index, params: { format: :json }
      expect(I18n.locale.to_s).to eq(@current_user.locale)
    end
  end

  describe "PUT #create" do
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

    it "should return error message if project wasn't created" do
      post :create, params: { name: "", format: :json }
      expect(response.body).to eq({ error: "can't be blank" }.to_json)
    end
  end

  describe "PUT #update" do
    login_admin
    let!(:project) { create(:project) }

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
      expect(response.body).to eq({ error: "can't be blank" }.to_json)
    end
  end

  describe "DELETE #destroy" do
    login_admin
    let!(:project) { create(:project) }

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
      allow(@current_user).to receive_message_chain(:projects, :find) { project }
      allow(project).to receive(:destroy) { false }
      project.errors.add(:base, "can't delete")
      delete :destroy, params: { id: project.id, format: :json }
      expect(response.body).to eq({ error: "can't delete" }.to_json)
    end
  end

  describe "PUT #assign_user" do
    login_admin
    let!(:project) { create(:project) }
    let(:user) { create(:user) }

    before do
      project.users << @current_user
    end

    it "should return success status if user was assigned to the project" do
      put :assign_user, params: { id: project.id, user_id: user.id, format: :json }
      expect(response.body).to eq({ success: true }.to_json)
    end

    it "should return error message if user wasn't assigned to the project" do
      allow(@curren_user).to receive_message_chain(:User, :find) { project }
      allow(project).to receive_message_chain(:users, :<<).and_raise(ActiveRecord::StaleObjectError)
      put :assign_user, params: { id: project.id, user_id: '111', format: :json }
      expect(response.body).to eq({ error: I18n.t("projects.errors.user_was_not_assigned") }.to_json)
    end
  end

  describe "PUT #remove_user" do
    login_admin
    let!(:project) { create(:project) }
    let(:user) { create(:user) }

    before do
      project.users << @current_user
    end

    it "should return success status if user was removed from project" do
      put :remove_user, params: { id: project.id, user_id: user.id, format: :json }
      expect(response.body).to eq({ success: true }.to_json)
    end

    it "should return error message if user wasn't removed from project" do
      allow(@curren_user).to receive_message_chain(:User, :find) { project }
      allow(project).to receive_message_chain(:users, :delete).and_raise(ActiveRecord::StaleObjectError)
      put :remove_user, params: { id: project.id, user_id: '111', format: :json }
      expect(response.body).to eq({ error: I18n.t("projects.errors.user_was_not_removed") }.to_json)
    end
  end

end
