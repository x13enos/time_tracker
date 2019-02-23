class User < ApplicationRecord
  serialize :password, EncryptedDataSerializer.new
end
