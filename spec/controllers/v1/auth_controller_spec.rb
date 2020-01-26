require 'rails_helper'

RSpec.describe V1::AuthController, type: :controller do
  let!(:user) { create(:user, password: '11111111') }

  describe "POST #create" do
    it "should find user by email" do
      expect(User).to receive(:find_by).with({ email: "example@gmail.com" }) { user }
      post :create, params: { email: "example@gmail.com", password: "1111", format: :json }
    end

    it "should try to authenticate user" do
      allow(User).to receive(:find_by).with({ email: "example@gmail.com" }) { user }
      expect(user).to receive(:authenticate).with('1111')
      post :create, params: { email: "example@gmail.com", password: "1111", format: :json }
    end

    it "should return user's info if its was authorized" do
      allow(User).to receive(:find_by).with({ email: "example@gmail.com" }) { user }
      allow(user).to receive(:authenticate) { user }
      post :create, params: { email: "example@gmail.com", password: "1111", format: :json }
      expect(response.body).to eq({
        email: user.email,
        name: user.name,
        timezone: user.timezone,
        role: user.role
      }.to_json)
    end

    it "should set token if user was authorized" do
      allow(User).to receive_message_chain(:find_by, :authenticate) { user }
      allow(TokenCryptService).to receive(:encode).with(user.email) { 'security_token' }
      post :create, params: { email: "example@gmail.com", password: "1111", format: :json }
      expect(cookies[:token]).to eq('security_token')
    end

    it "should return message and code status if user was not authorized" do
      allow(User).to receive(:find_by) { user }
      allow(user).to receive(:authenticate) { false }
      post :create, params: { email: "example@gmail.com", password: "1111", format: :json }
      expect(response.body).to eq({ error: "Unauthorized" }.to_json)
      expect(response.status).to eq(401)
    end
  end

  describe "DELETE #destroy" do
    login_staff

    it "should delete token" do
      cookies[:token] = "1111"
      delete :destroy, params: { format: :json }
      cookies.update(response.cookies)
      expect(cookies[:token]).to be_nil
    end

    it "should return user's info" do
      delete :destroy, params: { format: :json }
      expect(response.body).to eq({
        email: @current_user.email,
        name: @current_user.name,
        timezone: @current_user.timezone,
        role: @current_user.role
      }.to_json)
    end
  end
end