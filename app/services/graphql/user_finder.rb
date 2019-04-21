class Graphql::UserFinder

  def initialize(headers)
    @headers = headers
  end

  def perform
    return unless token_is_valid?
    find_user_by_decoded_token
  end

  private
  attr_reader :headers

  def token_is_valid?
    token.present? && token_is_suitable?
  end

  def token
    @token ||= headers["Authorization"]
  end

  def token_is_suitable?
    token.scan(/Bearer .*/).any?
  end

  def find_user_by_decoded_token
    begin
      email = TokenCryptService.decode(parsed_token)
      User.find_by(email: email)
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      nil
    end
  end

  def parsed_token
    token.gsub(/Bearer /, '')
  end
end
