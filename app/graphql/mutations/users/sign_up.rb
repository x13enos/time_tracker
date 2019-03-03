module Mutations
  module Users
    class SignUp < Mutations::BaseMutation
      argument :sign_up_data, Types::Users::AuthInput, required: true

      type Types::Users::Object

      def resolve(sign_up_data:)
        User.create!(
          email: sign_up_data.email,
          password: sign_up_data.password
        )
      rescue ActiveRecord::RecordInvalid => e
        GraphQL::ExecutionError.new(e)
      end
    end
  end
end
