module Types
  module Models
    class Project < Types::BaseObject
      global_id_field :id
      field :name, String, null: false
      field :users, [Types::Models::User], null: true
    end
  end
end
