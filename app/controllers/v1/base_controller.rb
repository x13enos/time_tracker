include ActionController::Cookies

class V1::BaseController < ApplicationController
  before_action :authenticate
  around_action :set_time_zone
  after_action :update_token, if: :logged_in?

  def current_user
    @current_user ||= if token.present? && decoded_token
      User.find_by(email: decoded_token)
    end
  end

  private

  def logged_in?
    !!current_user
  end

  def token
    @token ||= cookies[:token]
  end

  def authenticate
    authentication_error unless logged_in?
  end

  def authentication_error
    render json: { error: "Unauthorized" }, status: 401
  end

  def decoded_token
    @decoded_token ||= begin
                        TokenCryptService.decode(token)
                      rescue JWT::ExpiredSignature, JWT::DecodeError
                        false
                      end
  end

  def update_token
    cookies[:token] = {
      value: TokenCryptService.encode(current_user.email),
      secure: Rails.env.production?,
      httponly: true
    }
  end

  def set_time_zone
    timezone = current_user.try(:timezone) || "UTC"
    Time.use_zone(timezone) { yield }
  end
end
