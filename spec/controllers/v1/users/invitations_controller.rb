require 'rails_helper'

RSpec.describe V1::Users::InvitationsController, type: :controller do

  describe "PUT #update" do
    it "should return error in case of empty passed token" do
      put :update, params: { token: "", name: "", password: "", format: :json }
      expect(response.body).to eq({ error: I18n.t("passwords.token_does_not_present") }.to_json)
      expect(response.status).to eq(400)
    end

    it "should return error in case of empty passed name" do
      put :update, params: { token: "222", name: "", password: "", format: :json }
      expect(response.body).to eq({ error: I18n.t("passwords.name_does_not_present") }.to_json)
      expect(response.status).to eq(400)
    end

    it "should return error in case of empty passed password" do
      put :update, params: { token: "222", name: "test", password: "", format: :json }
      expect(response.body).to eq({ error: I18n.t("passwords.password_does_not_present") }.to_json)
      expect(response.status).to eq(400)
    end

    context "all params are valid" do
      let!(:user) { create(:user) }
      let(:request_params) { {
        token: "22222222",
        name: "John Doe",
        password: "8932479238",
        format: :json
      } }

      context "user was found by decoded token" do
        before do
          allow(TokenCryptService).to receive(:decode).with("22222222") { user.email }
        end

        it "should try to search user by decoded email" do
          expect(User).to receive(:find_by).with({ email: user.email }) { user }
          put :update, params: request_params
        end

        it "should set name for user" do
          allow(User).to receive(:find_by) { user }
          put :update, params: request_params
          expect(user.reload.name == 'John Doe').to be_truthy
        end

        it "should set password for user" do
          allow(User).to receive(:find_by) { user }
          put :update, params: request_params
          expect(user.reload.password == '8932479238').to be_truthy
        end

        it "should return 200 status" do
          allow(User).to receive(:find_by) { user }
          put :update, params: request_params
          expect(response.status).to eq(200)
        end

        it "should return 422 status if user's password wasn't updated" do
          allow(User).to receive(:find_by) { user }
          allow(user).to receive(:save!) { false }
          put :update, params: request_params
          expect(response.status).to eq(422)
        end

        it "should return error message if user's password wasn't updated" do
          allow(User).to receive(:find_by) { user }
          allow(user).to receive(:save!) { false }
          user.errors.add(:base, "error")
          put :update, params: request_params
          expect(response.body).to eq({ error: ["error"] }.to_json)
        end
      end

    end
  end
end
