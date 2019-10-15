include ActionController::Cookies

class GraphqlController < ApplicationController
  def execute
    find_user
    dataset = Graphql::SchemaExecutor.new(params, @user).perform
    set_new_token_to_cookies(dataset)
    render json: dataset
  rescue => e
    raise e unless Rails.env.development?
    handle_error_in_development(e)
  end

  private

  def find_user 
    @user = Graphql::UserFinder.new(cookies[:token]).perform
  end

  def set_new_token_to_cookies(dataset)
    token = Graphql::TokenSelector.new(@user, dataset).perform
    return unless token
    cookies[:token] = {
      value: token,
      secure: Rails.env.production?,
      httponly: true
    }
  end

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: { error: { message: e.message, backtrace: e.backtrace }, data: {} }, status: 500
  end
end
