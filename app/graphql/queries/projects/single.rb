module Queries
  module Projects
    class Single < Queries::BaseQuery
      argument :project_id, ID, required: true, loads: Types::Models::Project

      type Types::Models::Project, null: false

      def resolve(project:)
        return project
      end
    end
  end
end
