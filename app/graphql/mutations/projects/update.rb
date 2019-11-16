module Mutations
  module Projects
    class Update < Mutations::BaseMutation
      graphql_name 'ProjectUpdate'

      argument :name, String, required: true
      argument :project_id, ID, required: true, loads: Types::Models::Project

      field :project, Types::Models::Project, null: true

      def resolve(project:, name:)
        authorize(project)
        project.update!(name: name)
        return { project: project }
      rescue ActiveRecord::RecordInvalid => e
        GraphQL::ExecutionError.new(handle_invalid_record_message(e))
      end

    end
  end
end
