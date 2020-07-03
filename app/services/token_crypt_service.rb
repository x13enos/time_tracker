class TokenCryptService
  TOKEN_LIFETIME = 8.hours
  ALGORITHM_TYPE = 'HS256'

  class << self
    def encode(data, token_lifetime)
      payload = { data: data, exp: expiration_time(token_lifetime || TOKEN_LIFETIME).to_s.to_i  }
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

    def expiration_time(token_lifetime)
      Time.now.to_i + token_lifetime
    end
  end

end
