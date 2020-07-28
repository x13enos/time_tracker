class UserNotifier
  prepend TimeTrackerExtension::UserNotifier if EXTENSION_ENABLED

  def initialize(user, notification_type, args)
    @user = user
    @args = args
    @notification_type = notification_type
  end

  def perform
    I18n.with_locale(user.locale, &Proc.new { notifications })
  end

  private
  attr_reader :user, :notification_type, :args

  def notifications
    notify_by_email
  end

  def notify_by_email
    send_notification(Notifiers::Email)
  end

  def send_notification(notification_class)
    return unless notification_class.method_defined? notification_type
    notification_class.new(user, args).send(notification_type)
  end
end
