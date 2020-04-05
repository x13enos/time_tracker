class V1::ProjectsController < V1::BaseController
  def index
    authorize Project
    @projects = current_user.projects.order(:name)
  end

  def create
    authorize Project
    @project = Project.new(project_params)
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

  def assign_user
    authorize project
    begin
      project.users << user
      render json: { success: true }, status: 200
    rescue
      # TODO: send message to bug tracker about this
      render json: { error: I18n.t("projects.errors.user_was_not_assigned") }, status: 400
    end
  end

  def remove_user
    authorize project
    begin
      project.users.delete(user)
      render json: { success: true }, status: 200
    rescue
      # TODO: send message to bug tracker about this
      render json: { error: I18n.t("projects.errors.user_was_not_removed") }, status: 400
    end
  end

  private

  def generate_response
    if project.errors.any?
      render json: { error: project.errors.full_messages.join(", ") }, status: 400
    else
      render partial: '/v1/projects/show.json.jbuilder', locals: { project: project }
    end
  end

  def project
    @project ||= current_user.projects.find(params[:id])
  end

  def user
    User.find(params[:user_id])
  end

  def project_params
    params.permit(:name)
  end
end
