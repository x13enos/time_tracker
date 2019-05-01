require "rails_helper"

RSpec.describe Mutations::Projects::Delete do

  let(:result) { TimeTrackerSchema.execute(query_string) }
  let(:query_string) do
    %|mutation{
        deleteProject(
          projectId: "#{project_id}"
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
      let!(:project_id) { "UHJvamVjdC0x" }

      it "should update  project" do
        expect { result }.to change { Project.count }.from(1).to(0)
      end

      it "should return project's data" do
        expect(result['data']['deleteProject']['project']['id']).to eq(project_id)
      end
    end

    context "when passed id is wrong" do
      let!(:project_id) { "UHJvamVjdC0y" }

      it "should return error if project with passed id wasn't find" do
        expect(result["errors"][0]["message"]).to eq("Passed id is wrong or record didn't find")
      end
    end
  end
end
