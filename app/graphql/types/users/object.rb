module Types
  module Users
    class Object < Types::BaseObject
      field :id, ID, null: false
      field :name, String, null: true
      field :email, String, null: false
      field :password, String, null: false
    end
  end
end
