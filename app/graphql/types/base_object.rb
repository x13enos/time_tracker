module Types
  class BaseObject < GraphQL::Schema::Object
    field_class GraphQL::Pundit::Field
  end
end
