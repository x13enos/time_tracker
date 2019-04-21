module Mutations
  module Users
    class SignIn < Mutations::BaseMutation
      argument :sign_in_data, Types::Users::SignInInput, required: true

      field :token, String, null: true
      field :user, Types::Users::Object, null: true

      def resolve(sign_in_data:)
        authenticate_user(sign_in_data)
        if user
          { user: user, token: get_token }
        else
          GraphQL::ExecutionError.new("Email or Password are wrong.")
        end
      end

      private
      attr_reader :user

      def get_token
        TokenCryptService.encode(user.email)
      end

      def authenticate_user(auth_data)
        not_auth_user = User.find_by(email: auth_data[:email])
        return unless not_auth_user

        @user = not_auth_user.authenticate(auth_data[:password])
      end

    end
  end
end
