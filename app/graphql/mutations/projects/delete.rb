module Mutations
  module Projects
    class Delete < Mutations::BaseMutation
      argument :project_id, ID, required: true, loads: Types::Models::Project

      field :project, Types::Models::Project, null: true

      def resolve(project:)
        authorize(project)
        project.destroy
        return { project: project }
      rescue ActiveRecord::RecordInvalid => e
        GraphQL::ExecutionError.new(e)
      end

    end
  end
end
