class TimeTrackerSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  def self.object_from_id(unique_id, context)
    begin
      type_name, item_id = GraphQL::Schema::UniqueWithinType.decode(unique_id)
      Object.const_get(type_name).send(:find, item_id)
    rescue
      raise GraphQL::ExecutionError, "Passed id is wrong or record didn't find"
    end
  end

  def self.id_from_object(object, type_definition, query_ctx)
    GraphQL::Schema::UniqueWithinType.encode(type_definition.name, object.id)
  end
end
