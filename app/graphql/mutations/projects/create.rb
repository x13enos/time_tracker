module Mutations
  module Projects
    class Create < Mutations::BaseMutation

      argument :name, String, required: true

      field :project, Types::Models::Project, null: false

      def resolve(name:)
        project = Project.create!(name: name)
        return { project: project }
      rescue ActiveRecord::RecordInvalid => e
        GraphQL::ExecutionError.new(e)
      end

    end
  end
end
