class V1::ProjectsController < V1::BaseController
  def index
    authorize Project
    @projects = current_user.projects
                            .by_workspace(current_workspace_id)
                            .order(:name)
  end

  def create
    authorize Project
    @project = Project.new(project_params)
    @project.workspace_id = current_workspace_id
    @project.users = [current_user]
    @project.save
    generate_response
  end

  def update
    authorize project
    project.update(project_params)
    generate_response
  end

  def destroy
    authorize project
    project.destroy
    generate_response
  end

  private

  def generate_response
    if project.errors.any?
      render json: { errors: project.errors }, status: 400
    else
      render partial: '/v1/projects/show.json.jbuilder', locals: { project: project }
    end
  end

  def project
    @project ||= current_user.projects
                             .by_workspace(current_workspace_id)
                             .find(params[:id])
  end

  def user
    User.find(params[:user_id])
  end

  def project_params
    params.permit(:name, :regexp_of_grouping)
  end
end
