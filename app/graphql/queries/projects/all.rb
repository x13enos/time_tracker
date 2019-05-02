module Queries
  module Projects
    class All < Queries::BaseQuery

      type [Types::Models::Project], null: false

      def resolve
        authorize('project')
        Project.order(created_at: :desc)
      end

    end
  end
end
