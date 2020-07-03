class V1::AuthController < V1::BaseController
  include ViewHelpers

  skip_before_action :authenticate
  skip_after_action :set_token

  def index
    if current_user
      render_json_partial('/v1/users/show.json.jbuilder', { user: current_user })
    else
      render json: { error: I18n.t("auth.errors.unathorized") }, status: 401
    end
  end

  def create
    not_auth_user = User.find_by(email: auth_params[:email])
    user = not_auth_user&.authenticate(auth_params[:password])
    if user
      manage_token_for_user(user)
      render_json_partial('/v1/users/show.json.jbuilder', { user: user })
    else
      render json: { errors: { base: I18n.t("auth.errors.unathorized") } }, status: 401
    end
  end

  def destroy
    authorize :auth
    cookies.delete(:token)
    render_json_partial('/v1/users/show.json.jbuilder', { user: current_user })
  end

  private

  def auth_params
    params.permit(:email, :password)
  end

  def manage_token_for_user(user)
    if ActiveModel::Type::Boolean.new.cast(params[:remember_me])
      set_cookie(:remember_me, true)
      set_token(user, 30.days)
    else
      set_token(user)
    end
  end
end
