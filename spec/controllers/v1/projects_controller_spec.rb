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
        { id: project.id, name: project.name },
        { id: project_2.id, name: project_2.name}
      ].to_json)
    end

    it "should set locale if user was authorized" do
      get :index, params: { format: :json }
      expect(I18n.locale.to_s).to eq(@current_user.locale)
    end
  end
end
