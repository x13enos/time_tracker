module Queries
  module Users
    class PersonalInfo < Queries::BaseQuery

      type Types::Models::User, null: true

      def resolve
        authorize('user')
        return context[:current_user]
      end
    end
  end
end
