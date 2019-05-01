require "rails_helper"

RSpec.describe Queries::Projects::Single do

  let(:result) { TimeTrackerSchema.execute(query_string) }
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

      it "should return project's data" do
        expect(result['data']['project']).to eq({
          "id" => "UHJvamVjdC0x",
          "name" => project.name
        })
      end
    end
  end
end
