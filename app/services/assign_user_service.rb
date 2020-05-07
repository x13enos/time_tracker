class AssignUserService

  def initialize(email, admin, workspace)
    @email = email
    @admin = admin
    @workspace = workspace
  end

  def perform
    get_user
    add_user_to_workspace
    return user
  end

  private
  attr_reader :email, :admin, :workspace, :user

  def get_user
    @user ||= User.find_by(email: email) || create_user
  end

  def create_user
    @new_record = true
    @password = SecureRandom.urlsafe_base64(8)
    user = User.new({ email: email, active_workspace_id: workspace.id, role: :staff })
    user.password = @password
    user.save
    return user
  end

  def add_user_to_workspace
    workspace.users << user
    @new_record ? send_invitation_email : send_email_about_assigning_user
  end

  def send_invitation_email
    UserMailer.invitation_email(invitation_data.merge(password: @password)).deliver_now
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
