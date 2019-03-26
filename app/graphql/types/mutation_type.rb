module Types
  class MutationType < Types::BaseObject
    field :create_user, mutation: Mutations::Users::SignUp
    field :sign_in_user, mutation: Mutations::Users::SignIn
  end
end
