require "rails_helper"

RSpec.describe Queries::Projects::All do

  let(:result) { TimeTrackerSchema.execute(query_string) }
  let(:query_string) do
    %|query{
      allProjects  {
    		id,
        name
      }
    }|
  end

  describe "resolve" do
    context "when passed data is correct" do
      let!(:project) { create(:project, id: 1) }
      let!(:project_id) { "UHJvamVjdC0x" }

      it "should return projects data" do
        expect(result['data']['allProjects']).to eq([{
          "id" => project_id,
          "name" => project.name
        }])
      end
    end
  end
end
