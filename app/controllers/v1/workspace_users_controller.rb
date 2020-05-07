class V1::WorkspaceUsersController < V1::BaseController
  def create
    authorize workspace
    begin
      user = AssignUserService.new(params[:email], current_user, workspace).perform
      render partial: '/v1/users/show.json.jbuilder', locals: { user: user.reload }
    rescue
      render json: { error: I18n.t("workspaces.errors.user_was_not_invited") }, status: 400
    end
  end

  def destroy
    authorize workspace
    begin
      workspace.users.delete(User.find(params[:id]))
      render json: { success: true }, status: 200
    rescue
      render json: { error: I18n.t("workspaces.errors.user_was_not_removed") }, status: 400
    end
  end

  private

  def workspace
    @workspace ||= current_user.workspaces.find(params[:workspace_id])
  end
end