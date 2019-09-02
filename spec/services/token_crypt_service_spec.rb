require "rails_helper"

RSpec.describe TokenCryptService do
  include ActiveSupport::Testing::TimeHelpers

  before do
    allow(ENV).to receive(:[]).with("JWT_KEY").and_return("secret_key")
  end

  describe "encode" do
    it "should call JWT with the right params" do
      freeze_time do
        expiration_time = Time.now.to_i + TokenCryptService::TOKEN_LIFETIME
        payload = { data: "admin@gmail.com", exp: expiration_time.to_s.to_i  }
        expect(JWT).to receive(:encode).with(payload, "secret_key", TokenCryptService::ALGORITHM_TYPE)
        TokenCryptService.encode("admin@gmail.com")
      end
    end

    it "should return encoded data" do
      allow(JWT).to receive(:encode) { "encoded_data" }
      expect(TokenCryptService.encode("admin@gmail.com")).to eq("encoded_data")
    end
  end

  describe "decode" do
    let(:decoded_data) { [{ "data" => 'decoded_data' }] }

    it "should call JWT with the right params" do
      freeze_time do
        expect(JWT).to receive(:decode).with(
          "admin@gmail.com",
          "secret_key",
          true,
          { algorithm: TokenCryptService::ALGORITHM_TYPE }) { decoded_data }
        TokenCryptService.decode("admin@gmail.com")
      end
    end

    it "should return encoded data" do
      allow(JWT).to receive(:decode) { decoded_data }
      expect(TokenCryptService.decode("admin@gmail.com")).to eq("decoded_data")
    end
  end
end
