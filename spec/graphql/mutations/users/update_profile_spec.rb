require "rails_helper"

RSpec.describe Mutations::Users::UpdateProfile do

  let(:result) { TimeTrackerSchema.execute(query_string, context: { current_user: user }) }
  let(:query_string) do
    %| mutation{
        updateUserProfile(
        userData: {
          email: "new_example@user.com",
          name: "new name",
          timezone: "Athens",
          password: "22222222"
        }
      ) {
        user{
          name,
          email,
          timezone
        }
      }
    }|
  end

  describe "resolve" do
    context "when user was authenticated" do
      let!(:user) { create(:user, email: 'example@user.com', password: '11111111') }

      it "should return user data" do
        expect(result['data']['updateUserProfile']['user']).to_not be_empty
      end

      it "should update users data" do
        result
        expect(user.reload.attributes.slice("name", "email", "timezone")).to eq({
          email: "new_example@user.com",
          name: "new name",
          timezone: "Athens"
        }.stringify_keys)
      end
    end

    context "when user was not authenticated" do
      let!(:user) { nil }

      it "should return error" do
        expect(result["errors"][0]["message"]).to eq("User must be logged in")
      end
    end
  end
end
