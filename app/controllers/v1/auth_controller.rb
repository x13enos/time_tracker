class V1::AuthController < V1::BaseController
  skip_before_action :authenticate
  skip_after_action :update_token

  def create
    not_auth_user = User.find_by(email: auth_params[:email])
    user = not_auth_user&.authenticate(auth_params[:password])
    if user
      set_token(user)
      render partial: '/v1/users/show.json.jbuilder', locals: { user: user }
    else
      render json: { error: "Unauthorized" }, status: 401
    end
  end

  def destroy
    cookies.delete(:token)
    render partial: '/v1/users/show.json.jbuilder', locals: { user: current_user }
  end

  private

  def set_token(user)
    cookies[:token] = {
      value: TokenCryptService.encode(user.email),
      secure: Rails.env.production?,
      httponly: true
    }
  end

  def auth_params
    params.permit(:email, :password)
  end
end
