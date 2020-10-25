class UserNotifier
  prepend TimeTrackerExtension::UserNotifier if EXTENSION_ENABLED

  def initialize(notification_data)
    @user = notification_data[:user]
    @additional_data = notification_data[:additional_data]
    @notification_type = notification_data[:notification_type]
    @workspace_id = notification_data[:workspace_id]
  end

  def perform
    I18n.with_locale(user.locale, &Proc.new { notifications })
  end

  private
  attr_reader :user, :notification_type, :additional_data, :workspace_id

  def notifications
    notify_by_email
  end

  def notify_by_email
    return unless notification_found_in_settings?('email')
    Notifiers::Email.new(user, additional_data).send(notification_type)
  end

  def notification_found_in_settings?(notifier_type)
    user.notification_settings(workspace_id).include?("#{notifier_type}_#{notification_type}")
  end
end
