module Mutations
  module Projects
    class AssignUser < Mutations::BaseMutation

      argument :project_id, ID, required: true, loads: Types::Models::Project
      argument :user_id, ID, required: true, loads: Types::Models::User

      field :user, Types::Models::User, null: true
      field :project, Types::Models::Project, null: true

      def resolve(project:, user:)
        project.users << user
        return { user: user, project: project }
      rescue ActiveRecord::RecordNotFound => e
        GraphQL::ExecutionError.new(e)
      end

    end
  end
end
