class V1::AuthController < V1::BaseController
  skip_before_action :authenticate
  skip_after_action :set_token

  def index
    if current_user
      render partial: '/v1/users/show.json.jbuilder', locals: { user: current_user }
    else
      render json: { error: I18n.t("auth.errors.unathorized") }, status: 401
    end
  end

  def create
    not_auth_user = User.find_by(email: auth_params[:email])
    user = not_auth_user&.authenticate(auth_params[:password])
    if user
      set_token(user)
      render partial: '/v1/users/show.json.jbuilder', locals: { user: user }
    else
      render json: { errors: { base: I18n.t("auth.errors.unathorized") } }, status: 401
    end
  end

  def destroy
    authorize :auth
    cookies.delete(:token)
    render partial: '/v1/users/show.json.jbuilder', locals: { user: current_user }
  end

  private

  def auth_params
    params.permit(:email, :password)
  end
end
