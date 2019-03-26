class TokenCryptService
  TOKEN_LIFETIME = 15.minutes
  ALGORITHM_TYPE = 'HS256'

  class << self
    def encode(data)
      payload = { data: data, exp: expiration_time.to_s  }
      JWT.encode(payload, secret_key, ALGORITHM_TYPE)
    end

    def decode(token)
      decoded_data = JWT.decode(token, secret_key, true, { algorithm: ALGORITHM_TYPE })
      decoded_data.first['data']
    end

    private

    def secret_key
      ENV["JWT_KEY"]
    end

    def expiration_time
      Time.now.to_i + TOKEN_LIFETIME
    end
  end

end
