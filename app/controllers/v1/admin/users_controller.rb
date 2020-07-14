class V1::Admin::UsersController < V1::BaseController

  def index
    authorize([:admin, User])
    @users = User.includes(:workspaces).where(workspaces: { id:  current_workspace_id } )
  end

end
