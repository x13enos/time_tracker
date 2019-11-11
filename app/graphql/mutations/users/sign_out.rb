module Mutations
  module Users
    class SignOut < Mutations::BaseMutation
      graphql_name 'UserSignOut'
      
      field :user, Types::Models::User, null: true

      def resolve()
        authorize("user")
        { user: context[:current_user] }
      rescue ActiveRecord::RecordInvalid => e
        GraphQL::ExecutionError.new(e)
      end
    end
  end
end
