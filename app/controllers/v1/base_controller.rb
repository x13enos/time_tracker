include ActionController::Cookies

class V1::BaseController < ApplicationController
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :authentication_error

  before_action :authenticate
  around_action :set_time_zone
  around_action :with_locale, if: :current_user
  after_action :set_token, if: :token_should_be_refresh

  def current_user
    @current_user ||= if token.present? && decoded_token
      User.find_by(email: decoded_token)
    end
  end

  def current_workspace_id
    @current_workspace_id ||= if current_user
      current_user.active_workspace_id
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
    @decoded_token ||= decode(token)
  end

  def decode(passed_token)
    begin
      TokenCryptService.decode(passed_token)
    rescue JWT::ExpiredSignature
      cookies.delete(:remember_me)
      false
    rescue JWT::DecodeError
      false
    end
  end

  def set_token(user=current_user, token_lifetime=nil)
    token = TokenCryptService.encode(user.email, token_lifetime)
    set_cookie(:token, token)
  end

  def set_cookie(key, value)
    cookies[key] = {
      value: value,
      secure: Rails.env.production?,
      httponly: true
    }
  end

  def with_locale(&block)
    I18n.with_locale(current_user.locale, &block)
  end

  def token_should_be_refresh
    !cookies[:remember_me]
  end

  def set_time_zone
    timezone = ActiveSupport::TimeZone[params["timezone_offset"].to_i]
    Time.use_zone(timezone) { yield }
  end
end
