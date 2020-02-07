class V1::ProjectsController < V1::BaseController
  def index
    authorize Project
    @projects = current_user.projects.order(:name)
  end
end
