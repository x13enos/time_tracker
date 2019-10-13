class Graphql::UserFinder

  def initialize(token)
    @token = token
  end

  def perform
    return if token.nil?
    find_user_by_decoded_token
  end

  private
  attr_reader :token

  def find_user_by_decoded_token
    begin
      email = TokenCryptService.decode(token)
      User.find_by(email: email)
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      nil
    end
  end
end
