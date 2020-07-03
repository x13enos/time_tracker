class V1::ProjectUsersController < V1::BaseController
  def create
    authorize project, policy_class: ProjectUserPolicy
    begin
      project.users << user
      UserNotifier.new(user, :assign_user_to_project, { project: project }).perform
      render partial: '/v1/users/show.json.jbuilder', locals: { user: user.reload }
    rescue
      render json: { error: I18n.t("projects.errors.user_was_not_invited") }, status: 400
    end
  end

  def destroy
    authorize project, policy_class: ProjectUserPolicy
    begin
      project.users.delete(user)
      render json: { success: true }, status: 200
    rescue
      render json: { error: I18n.t("projects.errors.user_was_not_removed") }, status: 400
    end
  end

  private

  def project
    @project ||= current_user.projects.find(params[:project_id])
  end

  def user
    id = params[:user_id] || params[:id]
    @user ||= current_user.active_workspace.users.find(id)
  end
end
