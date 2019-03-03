class User < ApplicationRecord
  serialize :password, EncryptedDataSerializer.new

  validates :email, :password, presence: true
  validates :email, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { in: 8..32 }
end
