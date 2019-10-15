require "rails_helper"

RSpec.describe Graphql::TokenSelector do

  describe "#perform" do
    it "should return nil if user wansn't found and result doesn't contain info about sign in action" do
      user = nil
      result = { "data" => { "updateUser" => "" }}
      expect(Graphql::TokenSelector.new(user, result).perform).to be_nil
    end

    it "should return encoded email if user was passed" do
      user = create(:user, email: "user@example.com")
      result = { "data" => { "updateUser" => "" }}
      allow(TokenCryptService).to receive(:encode).with("user@example.com") { "super token" }
      expect(Graphql::TokenSelector.new(user, result).perform).to eq("super token")
    end

    it "should return token from result data" do
      user = nil
      result = { "data" => { "signInUser" =>  { "token" => "another token" } }}
      expect(Graphql::TokenSelector.new(user, result).perform).to eq("another token")
    end
  end
end
