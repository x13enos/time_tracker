module Mutations
  module Projects
    class Delete < Mutations::BaseMutation
      graphql_name 'ProjectDelete'

      argument :project_id, ID, required: true, loads: Types::Models::Project

      field :project, Types::Models::Project, null: true

      def resolve(project:)
        authorize(project)
        project.destroy
        return { project: project }
      rescue ActiveRecord::RecordInvalid => e
        GraphQL::ExecutionError.new(handle_invalid_record_message(e))
      end

    end
  end
end
