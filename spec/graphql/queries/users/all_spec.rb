require "rails_helper"

RSpec.describe Queries::Users::All do

  let!(:context) { { current_user: current_user } }
  let(:result) { TimeTrackerSchema.execute(query_string, context: context) }
  let(:query_string) do
    %|query{
      allUsers{
        id,
    		name,
        email,
        timezone,
        role
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
      let!(:current_user) { create(:user, :admin) }

      it "should return all users" do
        another_user = create(:user)
        expect(result["data"]["allUsers"].length).to eq(2)
      end

      it "should return all needed fields for user" do
        another_user = create(:user)
        expect(result["data"]["allUsers"][0]).to eq({
          "email" => current_user.email,
          "id" => encode_id(current_user),
          "timezone" => current_user.timezone,
          "name" => current_user.name,
          "role" => current_user.role
        })
      end
    end
  end
end
