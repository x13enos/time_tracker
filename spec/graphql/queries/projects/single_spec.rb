require "rails_helper"

RSpec.describe Queries::Projects::Single do

  let!(:current_user) { create(:user, :admin) }
  let!(:context) { { current_user: current_user } }
  let(:result) { TimeTrackerSchema.execute(query_string, context: context) }
  let(:query_string) do
    %|query{
      project(
        projectId: "UHJvamVjdC0x"
      )  {
    		id,
        name
      }
    }|
  end

  describe "resolve" do
    context "when passed data is correct" do
      let!(:project) { create(:project, id: 1) }

      context "not authorized" do
        let!(:current_user) { create(:user, :staff) }

        it "should return error" do
          expect(result["errors"][0]["message"]).to eq("You are not authorized to perform this action.")
        end
      end

      it "should return project's data" do
        expect(result['data']['project']).to eq({
          "id" => "UHJvamVjdC0x",
          "name" => project.name
        })
      end
    end
  end
end
