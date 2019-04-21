require 'rails_helper'

RSpec.describe GraphqlController, type: :request do
  let(:headers) { { "Authorization" => "Bearer 123123" } }

  describe "POST #execute" do
    it "should launch scheme executor service with the right attributes" do
      params = double
      allow(controller).to receive(:params) { params }
      allow(Graphql::SchemaExecutor).to receive(:new).with(controller.params, headers) { double(perform: true) }
      post "/graphql", params: { query: "query", format: :json }, headers: headers
    end

    it "should return json data" do
      result = { status: "ok" }
      allow(Graphql::SchemaExecutor).to receive(:new) { double(perform: result) }
      post "/graphql", params: { query: "query", format: :json }, headers: headers
      expect(response.body).to eq(result.to_json)
    end
  end
end
