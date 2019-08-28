module Types
  class MutationType < Types::BaseObject
    #Users
    field :create_user, mutation: Mutations::Users::SignUp
    field :sign_in_user, mutation: Mutations::Users::SignIn

    #Projects
    field :create_project, mutation: Mutations::Projects::Create
    field :update_project, mutation: Mutations::Projects::Update
    field :delete_project, mutation: Mutations::Projects::Delete
    field :assign_user_to_project, mutation: Mutations::Projects::AssignUser

    #Time records
    field :create_time_record, mutation: Mutations::TimeRecords::Create
    field :update_time_record, mutation: Mutations::TimeRecords::Update
  end
end
