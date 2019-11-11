require "rails_helper"

RSpec.describe Mutations::Users::SignOut do
  let(:user) { create(:user) }
  let(:result) { TimeTrackerSchema.execute(query_string, context: { current_user: user }) }
  let(:query_string) do
    %| mutation{
        signOutUser{
          user{
            name
          }
        }
    }|
  end

  describe "resolve" do
    context "when user exist and authenticated" do
      it "should return user data" do
        expect(result['data']['signOutUser']['user']).to_not be_empty
      end
    end
  end
end
