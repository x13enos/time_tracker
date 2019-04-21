module Types
  module Users
    class SignUpInput < BaseInputObject
      description "Attributes for sign up"
      argument :email, String, required: true
      argument :password, String, required: true
      argument :role, String, required: true
    end
  end
end
