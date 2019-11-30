module Mutations
  module Users
    class UpdateProfile < Mutations::BaseMutation
      graphql_name 'UserUpdateProfile'

      argument :user_data, Types::Inputs::UserProfile, required: true

      field :user, Types::Models::User, null: true

      def resolve(user_data:)
        authorize('user')
        context[:current_user].update!(user_data.to_h)
        { user: context[:current_user].reload }
      rescue ActiveRecord::RecordInvalid => e
        GraphQL::ExecutionError.new(handle_invalid_record_message(e))
      end
    end
  end
end
