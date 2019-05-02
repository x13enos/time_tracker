require "rails_helper"
require "base64"

RSpec.describe Mutations::Users::SignUp do

  let!(:current_user) { create(:user, :admin) }
  let!(:context) { { current_user: current_user } }
  let(:result) { TimeTrackerSchema.execute(query_string, context: context) }

  describe "a specific query" do
    let(:query_string) do
      %| mutation{
          createUser(
            signUpData: {
              email: "user@gmail.com",
              password: "#{password}",
              role: "admin"
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

      context "not authorized" do
        let!(:current_user) { create(:user, :staff) }

        it "should return error" do
          expect(result["errors"][0]["message"]).to eq("You are not authorized to perform this action.")
        end
      end

      it "should create new user" do
        user_name = result["data"]["createUser"]["id"]
        last_user = User.order("created_at DESC").first
        id = Base64.encode64("User-#{last_user.id.to_s}").squish
        expect(user_name).to eq(id)
      end
    end

  end
end
