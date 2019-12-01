module Types
  class MutationType < Types::BaseObject
    #Users
    field :create_user, mutation: Mutations::Users::SignUp
    field :sign_in_user, mutation: Mutations::Users::SignIn
    field :sign_out_user, mutation: Mutations::Users::SignOut
    field :update_user_profile, mutation: Mutations::Users::UpdateProfile

    #Projects
    field :create_project, mutation: Mutations::Projects::Create
    field :update_project, mutation: Mutations::Projects::Update
    field :delete_project, mutation: Mutations::Projects::Delete
    field :assign_user_to_project, mutation: Mutations::Projects::AssignUser

    #Time records
    field :create_time_record, mutation: Mutations::TimeRecords::Create
    field :update_time_record, mutation: Mutations::TimeRecords::Update
    field :delete_time_record, mutation: Mutations::TimeRecords::Delete
  end
end
