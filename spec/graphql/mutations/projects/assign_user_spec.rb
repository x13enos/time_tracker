require "rails_helper"

RSpec.describe Mutations::Projects::AssignUser do

  let(:result) { TimeTrackerSchema.execute(query_string) }
  let(:query_string) do
    %|mutation{
        assignUserToProject(
          projectId: "#{project_id}",
          userId: "#{user_id}"
        ){
        project{
          id
        }
      }
    }|
  end

  describe "resolve" do
    context "when passed data is correct" do
      let!(:project) { create(:project, id: 1) }
      let!(:user) { create(:user, id: 1) }
      let!(:project_id) { "UHJvamVjdC0x" }
      let!(:user_id) { "VXNlci0x" }

      it "should assign user to project" do
        expect { result }.to change { project.users.count }.from(0).to(1)
      end

      it "should return project's data" do
        expect(result['data']['assignUserToProject']['project']['id']).to eq(project_id)
      end
    end

    context "when passed id is wrong" do
      let!(:project) { create(:project, id: 1) }
      let!(:user) { create(:user, id: 1) }
      let!(:project_id) { "UHJvamVjdC0y" }
      let!(:user_id) { "VXNlci0x" }

      it "should return error if project with passed id wasn't find" do
        expect(result["errors"][0]["message"]).to eq("Passed id is wrong or record didn't find")
      end
    end
  end
end
