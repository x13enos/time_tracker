class UserMailer < ApplicationMailer

  def invitation_email(user, password)
    @user = user
    @password = password
    mail(to: user.email, subject: "Welcome to the time tracker!")
  end

  def recovery_password_email(user)
    @user = user
    @token = TokenCryptService.encode(user.email)
    mail(to: user.email, subject: "Reset your Time Tracker account")
  end

end
