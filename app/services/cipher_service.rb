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
      cipher = OpenSSL::Cipher.new(ALGORITHM)
      cipher.send(method)
      cipher.key = key
      cipher.update(data) + cipher.final
    end

    def key
      ENV["SECRET_KEY"]
    end
  end
end
