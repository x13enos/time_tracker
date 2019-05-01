module Mutations
  module Projects
    class Delete < Mutations::BaseMutation
      argument :project_id, ID, required: true, loads: Types::Models::Project

      field :project, Types::Models::Project, null: true

      def resolve(project:)
        project.delete
        return { project: project }
      rescue e
        GraphQL::ExecutionError.new(e)
      end

    end
  end
end
