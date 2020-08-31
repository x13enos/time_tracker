module Users
  class BaseForm < BaseForm
    define_model_callbacks :create

    validates :email, :locale, :active_workspace_id, presence: true
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :password, length: { in: 8..32 }, allow_nil: true
    validates :locale, inclusion: { in: User::SUPPORTED_LANGUAGES,
      message: I18n.t("users.errors.locale_inclusion") }
    validate :active_workspace_is_one_of_users_workspaces

    ATTRIBUTES = %w[email locale active_workspace_id name password workspace_ids]

    attr_accessor *ATTRIBUTES
    attr_accessor :user, :created_at, :updated_at, :notification_rules

    private

    def active_workspace_is_one_of_users_workspaces
      unless workspace_ids.include?(active_workspace_id)
        errors.add(:active_workspace_id, I18n.t("users.errors.active_workspace_is_invalid"))
      end
    end

  end
end
