json.(user, :id, :email, :name, :role, :locale, :active_workspace_id)
json.notification_settings user.notification_settings.rules
