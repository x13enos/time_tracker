class V1::WorkspacesController < V1::BaseController
  def index
    authorize Workspace
    @workspaces = current_user.workspaces
  end

  def create
    authorize Workspace
    form = Workspaces::CreateForm.new(workspace_params, current_user)
    if form.save
      render partial: '/v1/workspaces/show.json.jbuilder', locals: { workspace: form.workspace }
    else
      render json: { errors: form.errors }, status: 400
    end
  end

  def update
    authorize workspace
    if @workspace.update(workspace_params)
      render partial: '/v1/workspaces/show.json.jbuilder', locals: { workspace: @workspace }
    else
      render json: { errors: workspace.errors }, status: 400
    end
  end

  def destroy
    authorize workspace
    if workspace.destroy
      render json: "ok", status: 200
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
end
