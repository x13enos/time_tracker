class UserMailer < ApplicationMailer

  def invitation_email(invitation_data)
    @invitation_data = invitation_data
    mail(to: invitation_data[:user].email, subject: "Welcome to the time tracker!")
  end

  def recovery_password_email(user)
    @user = user
    @token = TokenCryptService.encode(user.email, 1.hours)
    mail(to: user.email, subject: "Reset your Time Tracker account")
  end

  def assigning_to_workspace_email(invitation_data)
    @invitation_data = invitation_data
    mail(to: invitation_data[:user].email, subject: "You was assigned to new workspace!")
  end
end
