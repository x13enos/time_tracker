require 'rails_helper'

RSpec.describe GraphqlController, type: :controller do

  describe "POST #execute" do

    context "finding user" do
      before do
        allow_any_instance_of(Graphql::SchemaExecutor).to receive(:perform)
        allow(controller).to receive(:set_new_token_to_cookies)
      end

      it "should build new instance of service for getting user" do
        request.cookies[:token] = "token"
        expect(Graphql::UserFinder).to receive(:new).with("token") { double(perform: true) }
        post :execute, params: { format: :json }
      end

      it "should launch that service" do
        service = double
        request.cookies[:token] = "token"
        allow(Graphql::UserFinder).to receive(:new).with("token") { service }
        expect(service).to receive(:perform)
        post :execute, params: { format: :json }
      end

      it "should set user to the instance variable" do
        request.cookies[:token] = "token"
        allow(Graphql::UserFinder).to receive(:new).with("token") { double(perform: "user" )}
        post :execute, params: { format: :json }
        expect(controller.instance_variable_get(:@user)).to eq("user")
      end
    end

    context "set new token to the cookies" do
      before do
        allow_any_instance_of(Graphql::SchemaExecutor).to receive(:perform) { "result" }
        allow(Graphql::UserFinder).to receive(:new) { double(perform: "user" )}
      end

      it "should build new instance of service for selecting token" do
        expect(Graphql::TokenSelector).to receive(:new).with("user", "result") { double(perform: true) }
        post :execute, params: { format: :json }
      end

      it "should launch that service" do
        service = double
        allow(Graphql::TokenSelector).to receive(:new).with("user", "result") { service }
        expect(service).to receive(:perform)
        post :execute, params: { format: :json }
      end

      it "should add token to the cookies if it was selected" do
        allow(Graphql::TokenSelector).to receive(:new).with("user", "result") { double(perform: "super token") }
        post :execute, params: { format: :json }
        expect(cookies[:token]).to eq("super token")
      end

      it "should not add token to the cookies if it's nil" do
        allow(Graphql::TokenSelector).to receive(:new).with("user", "result") { double(perform: nil) }
        post :execute, params: { format: :json }
        expect(cookies[:token]).to be_nil
      end
    end
  end
end
