require "rails_helper"

RSpec.describe Mutations::Projects::Update do

  let!(:current_user) { create(:user, :admin) }
  let!(:context) { { current_user: current_user } }
  let(:result) { TimeTrackerSchema.execute(query_string, context: context) }
  let(:query_string) do
    %|mutation{
        updateProject(
          projectId: "#{project_id}"
          name:  "#{name}",
        ){
        project{
          id,
          name
        }
      }
    }|
  end

  describe "resolve" do
    context "when passed data is correct" do
      let!(:project) { create(:project, id: 1, name: 'old project') }
      let!(:project_id) { "UHJvamVjdC0x" }
      let!(:name) { "New project" }

      context "not authorized" do
        let!(:current_user) { create(:user, :staff) }

        it "should return error" do
          expect(result["errors"][0]["message"]).to eq("You are not authorized to perform this action.")
        end
      end

      it "should update  project" do
        expect { result }.to change { project.reload.name }.from("old project").to("New project")
      end

      it "should return project's data" do
        expect(result['data']['updateProject']['project']['name']).to eq('New project')
      end
    end

    context "when passed id is wrong" do
      let!(:project_id) { "UHJvamVjdC0y" }
      let!(:name) { "New project" }

      it "should return error if project with passed id wasn't find" do
        expect(result["errors"][0]["message"]).to eq("Passed id is wrong or record didn't find")
      end
    end

    context "when passed name is nil" do
      let!(:project) { create(:project, id: 1, name: 'old project') }
      let!(:project_id) { "UHJvamVjdC0x" }
      let!(:name) { nil }

      it "should return error if project got the empty name" do
        result
        expect(project.reload.name).to eq("old project")
      end
    end
  end
end
