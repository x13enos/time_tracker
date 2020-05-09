class V1::UsersController < V1::BaseController
  def index
    authorize User
    @users = User.all
  end

  def update
    authorize User
    if current_user.update(user_params)
      render partial: '/v1/users/show.json.jbuilder', locals: { user: current_user.reload }
    else
      render json: { error: current_user.errors.values.join(", ") }, status: 400
    end
  end

  private

  def user_params
    params.permit(:name, :email, :password, :locale, :active_workspace_id)
  end

end
