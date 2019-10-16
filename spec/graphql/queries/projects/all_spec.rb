require "rails_helper"

RSpec.describe Queries::Projects::All do

  let!(:current_user) { create(:user, :admin) }
  let!(:context) { { current_user: current_user } }
  let(:result) { TimeTrackerSchema.execute(query_string, context: context) }
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

      context "user wasn't passed" do
        let!(:current_user) { nil }

        it "should return error" do
          expect(result["errors"][0]["message"]).to eq("User must be logged in")
        end
      end

      context "not authorized" do
        let!(:current_user) { create(:user, :staff) }

        it "should return error" do
          expect(result["errors"][0]["message"]).to eq("You are not authorized to perform this action.")
        end
      end

      it "should return projects data" do
        expect(result['data']['allProjects']).to eq([{
          "id" => project_id,
          "name" => project.name
        }])
      end
    end
  end
end
