module Types
  module Models
    class User < Types::BaseObject
      global_id_field :id
      field :name, String, null: true
      field :email, String, null: false
      field :password, String, null: false
    end
  end
end
