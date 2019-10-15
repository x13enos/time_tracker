require "rails_helper"

RSpec.describe Graphql::SchemaExecutor do

  describe "#process" do
    let(:user) { "user" }
    let(:params) do
      {
        query: "1111",
        operationName: "update",
        variables: "raw variables"
      }
    end
    let(:hash_of_additional_data) do
      {
        variables: "variables",
        context: { current_user: "user" },
        operation_name: "update"
      }
    end

    it "should execute schema with all needed attributes" do
      allow(Graphql::Variables).to receive(:process).with("raw variables") { "variables" }
      expect(TimeTrackerSchema).to receive(:execute).with('1111', hash_of_additional_data)
      Graphql::SchemaExecutor.new(params, user).perform
    end
  end
end
