class Graphql::TokenSelector

  def initialize(user, result)
    @user = user
    @result = result
  end

  def perform
    return if token_unexist?
    select_and_return_token
  end

  private
  attr_reader :user, :result

  def token_unexist?
    user.nil? && result.dig("data", "signInUser").nil?
  end

  def select_and_return_token
    if user
      TokenCryptService.encode(@user.email)
    else
      result["data"]["signInUser"]["token"]
    end
  end
end
