require 'rails_helper'

RSpec.describe V1::UsersController, type: :controller do
  login_staff

  describe "PUT #update" do
    it "should return user's data if user info was updated" do
      put :update, params: { email: "example@gmail.com", format: :json }
      expect(response.body).to eq({
        email: @current_user.email,
        name: @current_user.name,
        timezone: @current_user.timezone,
        role: @current_user.role
      }.to_json)
    end

    it "should return error message if user info was not updated" do
      put :update, params: { email: "",  format: :json }
      expect(response.body).to eq({ errors: @current_user.errors.full_messages }.to_json)
    end
  end
end
