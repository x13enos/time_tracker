class UserMailer < ApplicationMailer

  def invitation_email(user, password)
    @user = user
    @password = password
    mail(to: user.email, subject: "Welcome to the time tracker!")
  end

end
