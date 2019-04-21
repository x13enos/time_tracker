module Types
  module Users
    class SignInInput < BaseInputObject
      description "Attributes for sign in"
      argument :email, String, required: true
      argument :password, String, required: true
    end
  end
end
