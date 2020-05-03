class User < ApplicationRecord
  SUPPORTED_LANGUAGES = %w(en ru)
  has_secure_password

  enum role: [:admin, :staff]

  validates :email, :locale, presence: true
  validates :email, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { in: 8..32 }, allow_nil: true
  validates :locale, inclusion: { in: SUPPORTED_LANGUAGES,
    message: I18n.t("users.errors.locale_inclusion") }

  has_and_belongs_to_many :projects, -> { distinct }
  has_and_belongs_to_many :workspaces, -> { distinct }
  belongs_to :active_workspace, class_name: "Workspace",
                                foreign_key: "active_workspace_id"

  has_many :time_records, dependent: :destroy
end
