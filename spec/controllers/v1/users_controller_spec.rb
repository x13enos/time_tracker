require 'rails_helper'

RSpec.describe V1::UsersController, type: :controller do

  def user_info(user)
    {
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      locale: user.locale
    }
  end

  describe "GET #index" do
    login_admin

    it "should return list of users" do
      get :index, params: { format: :json }
      expect(response.body).to eq([
        {
          id: @current_user.id,
          name: @current_user.name,
          email: @current_user.email
        }
      ].to_json)
    end
  end

  describe "PUT #update" do
    login_staff

    it "should return user's data if user info was updated" do
      put :update, params: { email: "example@gmail.com", format: :json }
      expect(response.body).to eq(user_info(@current_user).to_json)

    end

    it "should return error message if user info was not updated" do
      put :update, params: { email: "",  format: :json }
      expect(response.body).to eq({ error: @current_user.errors.values.join(", ") }.to_json)
    end
  end
end
