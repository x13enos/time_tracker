require "rails_helper"

RSpec.describe Graphql::Variables do

  describe ".process" do

    it "should parse string data and handle this as hash" do
      raw_variables = { "first" => "example" }
      expect(Graphql::Variables.process(raw_variables.to_json)).to eq(raw_variables)
    end

    it "should return nil if passed data is string and empty" do
      raw_variables = ""
      expect(Graphql::Variables.process(raw_variables.to_json)).to eq({})
    end

    it "should return passed data if it's hash" do
      raw_variables = { first: "example" }
      expect(Graphql::Variables.process(raw_variables)).to eq(raw_variables)
    end

    it "should return empty hash if passed data is nil" do
      expect(Graphql::Variables.process(nil)).to eq({})
    end

    it "should raise exception is passed data is something another" do
      expect { Graphql::Variables.process(1) }.to raise_error(ArgumentError, "Unexpected parameter: 1")
    end
  end
end
