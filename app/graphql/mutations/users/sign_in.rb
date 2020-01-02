module Mutations
  module Users
    class SignIn < Mutations::BaseMutation
      graphql_name 'UserSignIn'

      argument :sign_in_data, Types::Inputs::SignIn, required: true

      field :token, String, null: true
      field :user, Types::Models::User, null: true

      def resolve(sign_in_data:)
        authenticate_user(sign_in_data)
        if user
          update_user_timezone(sign_in_data[:timezone_offset])
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

      def authenticate_user(sign_in_data)
        not_auth_user = User.find_by(email: sign_in_data[:email])
        return unless not_auth_user

        @user = not_auth_user.authenticate(sign_in_data[:password])
      end

      def update_user_timezone(timezone_offset)
        return if user.timezone
        user.update(timezone: ActiveSupport::TimeZone[timezone_offset].tzinfo.name)
      end

    end
  end
end
