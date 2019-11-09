class User < ApplicationRecord
  has_secure_password

  enum role: [:admin, :staff]

  validates :email, presence: true
  validates :email, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { in: 8..32 }, allow_nil: true

  has_and_belongs_to_many :projects, -> { distinct }
  has_many :time_records, dependent: :destroy
end
