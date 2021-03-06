class AssignUserService

  def initialize(email, admin, workspace)
    @email = email
    @admin = admin
    @workspace = workspace
  end

  def perform
    get_user
    @new_record ? send_invitation_email : add_user_to_workspace
    return user
  end

  private
  attr_reader :email, :admin, :workspace, :user

  def get_user
    @user ||= User.find_by(email: email) || create_user
  end

  def create_user
    @new_record = true
    form = Users::CreateForm.new({
      email: email,
      active_workspace_id: workspace.id,
      workspace_ids: [workspace.id],
      locale: admin.locale
    })
    form.save
    return form.user
  end

  def add_user_to_workspace
    workspace.users << user
    send_email_about_assigning_user
  end

  def send_invitation_email
    UserMailer.invitation_email(invitation_data).deliver_now
  end

  def send_email_about_assigning_user
    UserMailer.assigning_to_workspace_email(invitation_data).deliver_now
  end

  def invitation_data
    {
      user: user,
      admin: admin,
      workspace: workspace
    }
  end
end
