require "rails_helper"

RSpec.describe Mutations::Users::SignUp do

  let(:result) { TimeTrackerSchema.execute(query_string) }

  describe "a specific query" do
    let(:query_string) do
      %| mutation{
          createUser(
            signUpData: {
              email: "user@gmail.com",
              password: "#{password}"
            }
          ) {
            id
          }
        }|
    end

    context "when active record returns error" do
      let(:password) { nil }

      it "should return error" do
        expect(result["errors"][0]["message"]).to_not be_empty
      end

      it "shouldn't raised validation record" do
        expect{ result }.to_not raise_error(ActiveRecord::RecordInvalid)

      end
    end

    context "when user can be created" do
      let(:password) { '11111111' }

      it "should create new user" do
        user_name = result["data"]["createUser"]["id"]
        expect(user_name).to eq(User.last.id.to_s)
      end
    end

  end
end
