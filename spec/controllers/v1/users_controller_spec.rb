require 'rails_helper'

RSpec.describe V1::UsersController, type: :controller do
  describe "GET #index" do
    login_admin

    it "should return list of users" do
      get :index, params: { format: :json }
      expect(response.body).to eq([
        {
          id: @current_user.id,
          name: @current_user.name
        }
      ].to_json)
    end
  end

  describe "PUT #update" do
    login_staff

    it "should return user's data if user info was updated" do
      put :update, params: { email: "example@gmail.com", format: :json }
      expect(response.body).to eq({
        email: @current_user.email,
        name: @current_user.name,
        timezone: @current_user.timezone,
        role: @current_user.role,
        locale: @current_user.locale
      }.to_json)
    end

    it "should return error message if user info was not updated" do
      put :update, params: { email: "",  format: :json }
      expect(response.body).to eq({ errors: @current_user.errors.full_messages }.to_json)
    end
  end
end
