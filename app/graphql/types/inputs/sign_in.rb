module Types
  module Inputs
    class SignIn < BaseInputObject
      description "Attributes for sign in"
      argument :email, String, required: true
      argument :password, String, required: true
    end
  end
end
