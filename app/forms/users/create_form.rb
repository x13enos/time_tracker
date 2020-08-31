module Users
  class CreateForm < Users::BaseForm
    prepend TimeTrackerExtension::Users::CreateFormExtension if EXTENSION_ENABLED
    validate :email_is_unique?

    def initialize(attributes)
      super(attributes)
    end

    def persist!
      create_user
      set_defaut_notification_settings
    end

    private

    def create_user
      @user = User.create(user_attributes)
    end

    def set_defaut_notification_settings
      @user.workspace_settings.update(notification_rules: ['email_assign_user_to_project'])
    end

    def email_is_unique?
      if User.where(email: email).any?
        errors.add(:email, I18n.t("users.errors.email_uniqueness"))
      end
    end

    def user_attributes
      as_json.slice(*ATTRIBUTES)
    end
  end
end
