class User < ApplicationRecord
  include TimeTrackerExtension::UserExtension if EXTENSION_ENABLED

  SUPPORTED_LANGUAGES = %w(en ru)
  has_secure_password validations: false

  enum role: [:admin, :staff]

  validates :email, :locale, :active_workspace_id, presence: true
  validates :email, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { in: 8..32 }, allow_nil: true
  validates :locale, inclusion: { in: SUPPORTED_LANGUAGES,
    message: I18n.t("users.errors.locale_inclusion") }
  validate :active_workspace_is_one_of_users_workspaces

  has_one :notification_settings
  has_many :time_records, dependent: :destroy
  has_and_belongs_to_many :projects, -> { distinct }
  has_and_belongs_to_many :workspaces, -> { distinct }
  belongs_to :active_workspace, class_name: "Workspace",
                                foreign_key: "active_workspace_id"

  accepts_nested_attributes_for :notification_settings, update_only: true

  private

  def active_workspace_is_one_of_users_workspaces
    unless workspace_ids.include?(active_workspace_id)
      errors.add(:active_workspace_id, I18n.t("users.errors.active_workspace_is_invalid"))
    end
  end
end
