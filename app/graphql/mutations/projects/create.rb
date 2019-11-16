module Mutations
  module Projects
    class Create < Mutations::BaseMutation
      graphql_name 'ProjectCreate'

      argument :name, String, required: true

      field :project, Types::Models::Project, null: false

      def resolve(name:)
        authorize('project')
        project = Project.create!(name: name)
        return { project: project }
      rescue ActiveRecord::RecordInvalid => e
        GraphQL::ExecutionError.new(handle_invalid_record_message(e))
      end

    end
  end
end
