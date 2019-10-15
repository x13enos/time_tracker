require "rails_helper"

RSpec.describe Graphql::UserFinder do

  describe "#perform" do

    context "passed token is invalid" do
      it "should return nil if token is empty" do
        headers = {}
        expect(Graphql::UserFinder.new(nil).perform).to be_nil
      end
    end

    it "should return user if passed token is valid" do
      user = create(:user)
      allow(TokenCryptService).to receive(:decode).with("123456789") { user.email }
      allow(User).to receive(:find_by).with({ email: user.email }) { user }
      expect(Graphql::UserFinder.new("123456789").perform).to eq(user)
    end

    it "should return nil if passed token return unexisted email" do
      user = create(:user, email: "user@example.com")
      allow(TokenCryptService).to receive(:decode).with("123456789") { "admin@example.com" }
      expect(Graphql::UserFinder.new("123456789").perform).to eq(nil)
    end
  end
end
