include ActionController::Cookies

class V1::BaseController < ApplicationController
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :authentication_error

  before_action :authenticate
  around_action :set_time_zone
  after_action :set_token

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
    render json: { error: I18n.t("unathorized") }, status: 401
  end

  def decoded_token
    @decoded_token ||= begin
                        TokenCryptService.decode(token)
                      rescue JWT::ExpiredSignature, JWT::DecodeError
                        false
                      end
  end

  def set_token(user=current_user)
    cookies[:token] = {
      value: TokenCryptService.encode(user.email),
      secure: Rails.env.production?,
      httponly: true
    }
  end

  def set_time_zone
    timezone = current_user.try(:timezone) || Time.zone.tzinfo.name
    Time.use_zone(timezone) { yield }
  end
end
