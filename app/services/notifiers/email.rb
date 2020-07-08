class Notifiers::Email < Notifiers::Base
  include TimeTrackerExtension::Notifiers::Email if EXTENSION_ENABLED

  def assign_user_to_project
    UserMailer.assign_user_to_project(user, args[:project]).deliver_now
  end

end
