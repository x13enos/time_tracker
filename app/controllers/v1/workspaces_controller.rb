class V1::WorkspacesController < V1::BaseController
  def index
    authorize Workspace
    @workspaces = current_user.workspaces
  end

  def create
    authorize Workspace
    @workspace = Workspace.new(workspace_params)
    @workspace.users << current_user
    if @workspace.save
      render partial: '/v1/workspaces/show.json.jbuilder'
    else
      render json: { error: @workspace.errors.values.join(", ") }, status: 400
    end
  end

  def update
    authorize workspace
    if @workspace.update(workspace_params)
      render partial: '/v1/workspaces/show.json.jbuilder'
    else
      render json: { error: workspace.errors.values.join(", ") }, status: 400
    end
  end

  def destroy
    authorize workspace
    if workspace.destroy
      render partial: '/v1/workspaces/show.json.jbuilder'
    else
      render json: { error: workspace.errors.values.join(", ") }, status: 400
    end
  end

  private
  
  def workspace_params
    params.permit(:name)
  end

  def workspace
    @workspace ||= current_user.workspaces.find(params[:id])
  end
end
