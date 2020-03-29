class V1::ProjectsController < V1::BaseController
  before_action :find_project, only: [:update, :destroy]

  def index
    authorize Project
    @projects = current_user.projects.order(:name)
  end

  def create
    authorize Project
    @project = current_user.projects.build(project_params)
    generate_response(@project.save)
  end

  def update
    authorize @project
    generate_response(@project.update(project_params))
  end

  def destroy
    authorize @project
    generate_response(@project.destroy)
  end

  private

  def generate_response(action_result)
    unless action_result
      render json: { error: @project.errors.full_messages.join(", ") }, status: 400
    else
      render partial: '/v1/projects/show.json.jbuilder', locals: { project: @project }
    end
  end

  def find_project
    @project = current_user.projects.find(params[:id])
  end

  def project_params
    params.permit(:name)
  end
end
