module Mutations
  module Projects
    class Update < Mutations::BaseMutation

      argument :name, String, required: true
      argument :project_id, ID, required: true, loads: Types::Models::Project

      field :project, Types::Models::Project, null: true

      def resolve(project:, name:)
        project.update!(name: name)
        return { project: project }
      rescue ActiveRecord::RecordInvalid => e
        GraphQL::ExecutionError.new(e)
      end

    end
  end
end
