require 'rails_helper'

RSpec.describe V1::Users::RegistrationsController, type: :controller do
  let!(:user) { create(:user, :staff) }

  describe "POST #create" do
    it "should build registration form" do
      expect(Users::RegistrateForm).to receive(:new) { double(save: true, user: user) }
      post :create, params: { email: "user@email.com", password: "11111111", format: :json }
    end

    it 'should set set token in cookies in case of succesfull creating' do
      allow(Users::RegistrateForm).to receive(:new) { double(save: true, user: user) }
      expect(controller).to receive(:set_token).with(user)
      post :create, params: { email: "user@email.com", password: "11111111", format: :json }
    end

    it "should render json partial with users data" do
      allow(Users::RegistrateForm).to receive(:new) { double(save: true, user: user) }
      post :create, params: { email: "user@email.com", password: "11111111", format: :json }
      expect(response.body).to eq({
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role,
          locale: user.locale,
          active_workspace_id: user.active_workspace_id,
          notification_settings: user.notification_settings,
          workspaces: [
            { id: user.active_workspace_id, name: user.active_workspace.name }
          ]
        }.to_json)
    end

    context "user's data was invalid" do
      before do
        allow(Users::RegistrateForm).to receive(:new) { double(save: false, errors: "Critical Error") }
        post :create, params: { email: "user@email.com", password: "11111111", format: :json }
      end

      it "should return json with errors" do
        expect(response.body).to eq({ errors: "Critical Error"}.to_json)
      end

      it "should return 400 code status" do
        expect(response.status).to eq(400)
      end
    end

  end
end