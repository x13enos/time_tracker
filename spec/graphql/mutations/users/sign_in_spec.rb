require "rails_helper"

RSpec.describe Mutations::Users::SignIn do

  let(:result) { TimeTrackerSchema.execute(query_string) }
  let(:query_string) do
    %| mutation{
        signInUser(
        signInData: {
          email: "example@user.com",
          password: "11111111"
        }
      ) {
        	token
        	user{
            id
          }
        }
    }|
  end

  describe "resolve" do
    context "when user exist and authenticated" do
      let!(:user) { create(:user, email: 'example@user.com', password: '11111111') }

      it "should return token" do
        allow(TokenCryptService).to receive(:encode).with(user.email) { 'secret_token' }
        expect(result['data']['signInUser']['token']).to eq('secret_token')
      end

      it "should return user data" do
        expect(result['data']['signInUser']['user']).to_not be_empty
      end
    end

    it "should return error if password is incorrect" do
      create(:user, email: 'example@user.com', password: '11111112')
      expect(result["errors"][0]["message"]).to eq("Email or Password are wrong.")
    end

    it "should return error if email is incorrect" do
      create(:user, email: 'example@user.cop', password: '11111111')
      expect(result["errors"][0]["message"]).to eq("Email or Password are wrong.")
    end
  end
end
