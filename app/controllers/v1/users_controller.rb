class V1::UsersController < V1::BaseController
  def update
    if current_user.update(user_params)
      render partial: '/v1/users/show.json.jbuilder', locals: { user: current_user.reload }
    else
      render json: { errors: current_user.errors.full_messages }, status: 400
    end
  end

  private

  def user_params
    params.permit(:name, :email, :timezone, :password)
  end
end