class CipherService
  ALGORITHM = "aes-256-cbc-hmac-sha1".freeze

  class << self
    def encrypt(data)
      crypt(:encrypt, data)
    end

    def decrypt(data)
      crypt(:decrypt, data)
    end

    private

    def crypt(method, data)
      new_cipher = OpenSSL::Cipher.new(ALGORITHM)
      new_cipher.send(method)
      new_cipher.key = key
      new_cipher.update(data) + new_cipher.final
    end

    def key
      ENV["SECRET_KEY"]
    end
  end
end
