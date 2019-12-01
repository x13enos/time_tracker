module Types
  module Inputs
    class UserProfile < BaseInputObject
      description "Attributes for updating user profile"
      argument :name, String, required: true
      argument :email, String, required: true
      argument :timezone, String, required: true
    end
  end
end
