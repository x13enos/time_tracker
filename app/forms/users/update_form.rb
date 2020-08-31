module Users
  class UpdateForm < Users::BaseForm
    validate :email_is_unique?

    def initialize(passed_attributes, user)
      @user = user
      @notification_rules = passed_attributes["notification_rules"]
      attributes = user.attributes.slice(*ATTRIBUTES).merge!(passed_attributes)
      attributes["workspace_ids"] = user.workspace_ids
      super(attributes)
    end


    def persist!
      update_user
      update_notifications_rules
    end

    private

    def update_user
      user.update!(update_attributes)
    end

    def update_notifications_rules
      user.workspace_settings.update(notification_rules: notification_rules)
    end

    def email_is_unique?
      if User.where("email = ? AND id <> ?", email, user.id).any?
        errors.add(:email, I18n.t("users.errors.email_uniqueness"))
      end
    end

    def update_attributes
      attributes = as_json.slice(*ATTRIBUTES)
      attributes.delete("password") if attributes["password"].nil?
      return attributes
    end
  end
end
