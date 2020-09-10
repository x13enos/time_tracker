class V1::UsersController < V1::BaseController
  include ViewHelpers

  def index
    authorize User
    workspace_ids = ActiveModel::Type::Boolean.new.cast(params[:current_workspace]) ? current_workspace_id : current_user.workspace_ids
    @users = User.includes(:workspaces).where(workspaces: { id:  workspace_ids } )
  end

  def update
    authorize User
    @form = Users::UpdateForm.new(user_params, current_user)
    if @form.save
      render_json_partial('/v1/auth/user.json.jbuilder', { user: @form.user.reload })
          else
            render json: { errors: @form.errors }, status: 400
          end
        end

  def change_workspace
    authorize User
    @form = Users::ChangeWorkspaceForm.new(params[:workspace_id], current_user)
    if @form.save
      render json: { status: 'ok' }, status: 200
    else
      render json: { errors: @form.errors }, status: 400
    end
  end

  private

  def user_params
    params.permit(
      :name,
      :email,
      :password,
      :locale,
      notification_rules: []
    )
  end
end
