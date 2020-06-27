class V1::UsersController < V1::BaseController
  include ViewHelpers

  def index
    authorize User
    get_users
  end

  def update
    authorize User
    if current_user.update(user_params)
      render_json_partial('/v1/users/show.json.jbuilder', { user: current_user.reload })
    else
      render json: { errors: current_user.reload.errors }, status: 400
    end
  end

  private

  def user_params
    params.permit(:name, :email, :password, :locale, :active_workspace_id)
  end

  def get_users
    workspace_ids = ActiveModel::Type::Boolean.new.cast(params[:current_workspace]) ? current_workspace_id : current_user.workspace_ids
    @users = User.includes(:workspaces).where(workspaces: { id:  workspace_ids } )
  end

end
