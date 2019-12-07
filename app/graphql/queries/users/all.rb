module Queries
  module Users
    class All < Queries::BaseQuery

      type [Types::Models::User], null: true

      def resolve
        authorize('user')
        User.all
      end
    end
  end
end
