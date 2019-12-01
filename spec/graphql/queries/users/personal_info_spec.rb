require "rails_helper"

RSpec.describe Queries::Users::PersonalInfo do

  let!(:context) { { current_user: current_user } }
  let(:result) { TimeTrackerSchema.execute(query_string, context: context) }
  let(:query_string) do
    %|query{
      personalInfo{
    		name,
        email,
        timezone
      }
    }|
  end

  describe "resolve" do

    context "not authorized" do
      let!(:current_user) { nil }

      it "should return error" do
        expect(result["errors"][0]["message"]).to eq("User must be logged in")
      end
    end

    context "authorized" do
      let!(:current_user) { create(:user) }

      it "should return user's data" do
        expect(result["data"]["personalInfo"]).to eq(
          current_user.attributes.slice("name", "email", 'timezone').stringify_keys
        )
      end
    end
  end
end
