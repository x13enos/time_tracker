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
    return unless notification_found_in_settings('email')
    Notifiers::Email.new(user, args).send(notification_type)
  end

  def notification_found_in_settings(notifier_type)
    user.notification_settings.rules.include?("#{notifier_type}_#{notification_type}")
  end
end
