module Mutations
  module Projects
    class AssignUser < Mutations::BaseMutation
      graphql_name 'ProjectAssignUser'

      argument :project_id, ID, required: true, loads: Types::Models::Project
      argument :user_id, ID, required: true, loads: Types::Models::User

      field :user, Types::Models::User, null: true
      field :project, Types::Models::Project, null: true

      def resolve(project:, user:)
        authorize(project)
        project.users << user
        return { user: user, project: project }
      rescue ActiveRecord::RecordNotFound => e
        GraphQL::ExecutionError.new(handle_invalid_record_message(e))
      end

    end
  end
end
