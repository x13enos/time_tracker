require 'rails_helper'

RSpec.describe V1::PasswordsController, type: :controller do

  describe "GET #forget" do
    it "should return error in case of empty passed email" do
      get :forgot, params: { email: "", format: :json }
      expect(response.body).to eq({ error: I18n.t("recovery_password.email_not_present") }.to_json)
      expect(response.status).to eq(400)
    end

    context "email was passed" do
      let!(:user) { create(:user) }
      it "should send email if user was found" do
        mailer = double
        allow(User).to receive(:find_by) { user }
        expect(UserMailer).to receive(:recovery_password_email).with(user) { mailer }
        expect(mailer).to receive(:deliver_now)

        get :forgot, params: { email: user.email, format: :json }
      end

      it "should return success status in json if user was found" do
        get :forgot, params: { email: user.email, format: :json }
        expect(response.body).to eq({ status: "ok" }.to_json)
      end

      it "should return 400 status if user was found" do
        get :forgot, params: { email: user.email, format: :json }
        expect(response.status).to eq(200)
      end

      it "should return error if user was not found" do
        get :forgot, params: { email: "test@gmail.com", format: :json }
        expect(response.body).to eq({
          error: I18n.t("recovery_password.user_not_found")
        }.to_json)
      end

      it "should return 404 if user was not found" do
        get :forgot, params: { email: "test@gmail.com", format: :json }
        expect(response.status).to eq(404)
      end
    end
  end

  describe "GET #reset" do
    it "should return error in case of empty passed token" do
      post :reset, params: { token: "", password: "", format: :json }
      expect(response.body).to eq({ error: I18n.t("recovery_password.token_not_present") }.to_json)
      expect(response.status).to eq(400)
    end

    it "should return error in case of empty passed password" do
      post :reset, params: { token: "2222", password: "", format: :json }
      expect(response.body).to eq({ error: I18n.t("recovery_password.password_not_present") }.to_json)
      expect(response.status).to eq(400)
    end

    it "should return error in case of not matching password and confirmed one" do
      post :reset, params: {
        token: "2222",
        password: "11111111",
        confirm_password: "999999999",
        format: :json
      }
      expect(response.body).to eq({ error: I18n.t("recovery_password.confirmation_password_does_not_match") }.to_json)
      expect(response.status).to eq(400)
    end

    # TokenCryptService.decode(passed_token)

    context "all params are valid" do
      let!(:user) { create(:user) }
      let(:request_params) { {
        token: "22222222",
        password: "8932479238",
        confirm_password: "8932479238",
        format: :json
      } }

      context "user was found by decoded token" do
        before do
          allow(TokenCryptService).to receive(:decode).with("22222222") { user.email }
        end

        it "should try to search user by decoded email" do
          expect(User).to receive(:find_by).with({ email: user.email }) { user }
          post :reset, params: request_params
        end

        it "should change password for user" do
          allow(User).to receive(:find_by) { user }
          post :reset, params: request_params
          expect(user.reload.password == '8932479238').to be_truthy
        end

        it "should return 200 status" do
          allow(User).to receive(:find_by) { user }
          post :reset, params: request_params
          expect(response.status).to eq(200)
        end

        it "should return 422 status if user's password wasn't updated" do
          allow(User).to receive(:find_by) { user }
          allow(user).to receive(:save!) { false }
          post :reset, params: request_params
          expect(response.status).to eq(422)
        end

        it "should return error message if user's password wasn't updated" do
          allow(User).to receive(:find_by) { user }
          allow(user).to receive(:save!) { false }
          user.errors.add(:base, "error")
          post :reset, params: request_params
          expect(response.body).to eq({ error: ["error"] }.to_json)
        end
      end

      it "should return error message if token was expired" do
        allow(TokenCryptService).to receive(:decode).with("22222222") { nil }
        post :reset, params: request_params
        expect(response.body).to eq({ error: I18n.t("recovery_password.invalid_token") }.to_json)
      end
    end
  end
end
