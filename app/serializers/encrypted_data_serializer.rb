class EncryptedDataSerializer
  def load(value)
    return unless value
    decoded_value = Base64.decode64(value)
    CipherService.decrypt(decoded_value)
  end

  def dump(value)
    encrypted_value = CipherService.encrypt(value)
    Base64.encode64(encrypted_value)
  end
end
