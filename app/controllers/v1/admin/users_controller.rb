class V1::Admin::UsersController < V1::BaseController
  include ViewHelpers

  def index
    authorize([:admin, User])
    @users = users_scope
  end

  def update
    authorize([:admin, User])
    user = users_scope.find(params[:id])
    @form = UsersWorkspaces::UpdateForm.new(user_params, user, current_workspace_id)
    if @form.save
      render_json_partial('/v1/auth/user.json.jbuilder', { user: user.reload })
    else
      render json: { errors: @form.errors }, status: 400
    end
  end

  private 

  def users_scope
    User.includes(:workspaces).where(workspaces: { id:  current_workspace_id } )
  end

  def user_params
    params.permit(:role)
  end

end
