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

  describe "POST #create" do
    login_admin

    it "should return user's data if user was created" do
      post :create, params: { name: "new user", email: "example@gmail.com", format: :json }
      expect(response.body).to eq(user_info(User.last).to_json)
    end

    it "should send an email to user it he was created" do
      mailer = double
      allow(UserMailer).to receive(:invitation_email) { mailer }
      expect(mailer).to receive(:deliver_now)
      post :create, params: { name: "new user", email: "example@gmail.com", format: :json }
    end

    it "should add user to DB" do
      expect{ post :create, params: { name: "new user", email: "example@gmail.com", format: :json } }.to change{ User.count }.from(1).to(2)
    end

    it "should add user to the current workspace" do
      post :create, params: { name: "new user", email: "example@gmail.com", format: :json }
      expect(@current_user.active_workspace.users).to include(User.find_by(email: "example@gmail.com"))
    end

    it "should set active workspace for new user" do
      post :create, params: { name: "new user", email: "example@gmail.com", format: :json }
      expect(User.find_by(email: "example@gmail.com").active_workspace_id).to eq(@current_user.active_workspace_id)
    end

    it "should generate and keep password for new user" do
      user = build(:user)
      allow(User).to receive(:new) { user }
      allow(SecureRandom).to receive(:urlsafe_base64) { "i3Sl4ro4" }
      post :create, params: { name: "new user", email: "example@gmail.com", format: :json }
      expect(user.reload.password == "i3Sl4ro4").to be_truthy
    end

    it "should return error message if user was not created" do
      user = build(:user)
      allow(User).to receive(:new) { user }
      allow(user).to receive(:save) { false }
      put :create, params: { name: "",  format: :json }
      expect(response.body).to eq({ error: user.errors.values.join(", ") }.to_json)
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

  describe "DELETE #destroy" do
    login_admin
    let!(:user) { create(:user) }

    it "should return user's data if it was deleted" do
      delete :destroy, params: { id: user.id, format: :json }
      expect(response.body).to eq(user_info(user).to_json)

    end

    it "should remove user" do
      expect { delete :destroy, params: { id: user.id, format: :json } }.to change { User.count }.from(2).to(1)
    end

    it "should return error message if user wasn't deleted" do
      allow(User).to receive_message_chain(:find) { user }
      allow(user).to receive(:destroy) { false }
      user.errors.add(:base, "can't delete")
      delete :destroy, params: { id: user.id, format: :json }
      expect(response.body).to eq({ error: "can't delete" }.to_json)
    end
  end
end
