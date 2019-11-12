include ActionController::Cookies

class GraphqlController < ApplicationController
  before_action :find_user
  around_action :set_time_zone

  def execute
    @dataset = Graphql::SchemaExecutor.new(params, @user).perform

    manage_user_session
    render json: @dataset
  rescue => e
    raise e unless Rails.env.development?
    handle_error_in_development(e)
  end

  private

  def find_user
    @user = Graphql::UserFinder.new(cookies[:token]).perform
  end

  def manage_user_session
    if should_user_be_signed_out?
      cookies.delete(:token)
    else
      create_or_update_user_session
    end
  end

  def should_user_be_signed_out?
    @dataset.dig("data", "signOutUser").present?
  end

  def create_or_update_user_session
    token = Graphql::TokenSelector.new(@user, @dataset).perform
    return unless token
    cookies[:token] = {
      value: token,
      secure: Rails.env.production?,
      httponly: true
    }
  end

  def set_time_zone
    timezone = @user.try(:timezone) || "UTC"
    Time.use_zone(timezone) { yield }
  end

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: { error: { message: e.message, backtrace: e.backtrace }, data: {} }, status: 500
  end
end
