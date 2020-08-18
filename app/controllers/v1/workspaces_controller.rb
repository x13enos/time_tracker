class V1::WorkspacesController < V1::BaseController
  def index
    authorize Workspace
    @workspaces = current_user.workspaces
  end

  def create
    authorize Workspace
    @workspace = Workspace.new(workspace_params)
    if @workspace.save
      assign_user_as_owner
      render partial: '/v1/workspaces/show.json.jbuilder'
    else
      render json: { errors: @workspace.errors }, status: 400
    end
  end

  def update
    authorize workspace
    if @workspace.update(workspace_params)
      render partial: '/v1/workspaces/show.json.jbuilder'
    else
      render json: { errors: workspace.errors }, status: 400
    end
  end

  def destroy
    authorize workspace
    if workspace.destroy
      render partial: '/v1/workspaces/show.json.jbuilder'
    else
      render json: { errors: workspace.errors }, status: 400
    end
  end

  private

  def workspace_params
    params.permit(:name)
  end

  def workspace
    @workspace ||= current_user.workspaces.find(params[:id])
  end

  def assign_user_as_owner
    @workspace.users << current_user
    current_user.users_workspaces.find_by(workspace_id: @workspace.reload.id).update(role: "owner")
  end
end
