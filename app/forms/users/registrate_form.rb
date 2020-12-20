module Users
  class RegistrateForm < Users::BaseForm
    prepend TimeTrackerExtension::Users::CreateFormExtension if EXTENSION_ENABLED
    validate :email_is_unique?

    def initialize(attributes)
      super(attributes)
    end

    def persist!
      create_default_workspace
      create_user
      add_user_to_default_workspace
      set_defaut_notification_settings
      send_welcome_email
    end

    private

    def create_default_workspace
      workspace_name = email.split("@")[0]
      @workspace = Workspace.create(name: workspace_name)
      self.active_workspace_id = @workspace.id
    end

    def create_user
      @user = User.create!(user_attributes)
    end

    def add_user_to_default_workspace
      @workspace.users << user
    end

    def set_defaut_notification_settings
      user.workspace_settings.update(
        notification_rules: ['email_assign_user_to_project'],
        role: 'owner'
      )
    end

    def send_welcome_email
      UserMailer.welcome_email(user).deliver_now
    end

    def user_attributes
      as_json.slice(*ATTRIBUTES)
    end
  end
end
