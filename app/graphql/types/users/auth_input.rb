module Types
  module Users
    class AuthInput < BaseInputObject
      description "Attributes for sign up/sign in"
      argument :email, String, required: true
      argument :password, String, required: true
    end
  end
end
