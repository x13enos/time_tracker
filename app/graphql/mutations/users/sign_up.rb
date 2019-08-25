module Mutations
  module Users
    class SignUp < Mutations::BaseMutation
      graphql_name 'UserSignUp'

      argument :sign_up_data, Types::Inputs::SignUp, required: true

      type Types::Models::User

      def resolve(sign_up_data:)
        authorize('user')
        User.create!(
          email: sign_up_data.email,
          password: sign_up_data.password,
          role: sign_up_data.role
        )
      rescue ActiveRecord::RecordInvalid => e
        GraphQL::ExecutionError.new(e)
      end
    end
  end
end
