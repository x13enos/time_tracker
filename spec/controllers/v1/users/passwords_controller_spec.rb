require 'rails_helper'

RSpec.describe V1::Users::PasswordsController, type: :controller do

  describe "GET #new" do
    it "should return error in case of empty passed email" do
      post :create, params: { email: "", format: :json }
      expect(response.body).to eq({ errors: { base:I18n.t("passwords.email_does_not_present") } }.to_json)
      expect(response.status).to eq(400)
    end

    context "email was passed" do
      let!(:user) { create(:user) }

      it "should send email if user was found" do
        mailer = double
        allow(User).to receive(:find_by) { user }
        expect(UserMailer).to receive(:recovery_password_email).with(user) { mailer }
        expect(mailer).to receive(:deliver_now)

        post :create, params: { email: user.email, format: :json }
      end

      it "should return success status in json if user was found" do
        post :create, params: { email: user.email, format: :json }
        expect(response.body).to eq({ status: "ok" }.to_json)
      end

      it "should return 200 status if user was found" do
        post :create, params: { email: user.email, format: :json }
        expect(response.status).to eq(200)
      end

      it "should set locale if locale was passed in params" do
        expect(I18n).to receive(:with_locale).with("ru")
        post :create, params: { email: user.email, format: :json, locale: "ru" }
      end
    end
  end

  describe "PUT #update" do
    it "should return error in case of empty passed token" do
      put :update, params: { token: "", password: "", format: :json }
      expect(response.body).to eql({ errors: { base: I18n.t("passwords.token_does_not_present") } }.to_json)
      expect(response.status).to eq(400)
    end

    it "should return error in case of empty passed password" do
      put :update, params: { token: "2222", password: "", format: :json }
      expect(response.body).to eql({ errors: { base: I18n.t("passwords.password_does_not_present") } }.to_json)
      expect(response.status).to eq(400)
    end

    context "all params are valid" do
      let!(:user) { create(:user) }
      let(:request_params) { {
        token: "22222222",
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

        it "should change password for user" do
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
          expect(response.body).to eq({ errors: { base: ["error"] } }.to_json)
        end
      end

      it "should return error message if token was expired" do
        allow(TokenCryptService).to receive(:decode).with("22222222") { nil }
        put :update, params: request_params
        expect(response.body).to eq({ errors: { base: I18n.t("passwords.invalid_token") } }.to_json)
      end
    end
  end
end
