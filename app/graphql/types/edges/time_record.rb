class Types::Edges::TimeRecord < GraphQL::Types::Relay::BaseEdge
  graphql_name 'TimeRecordEdgeType'
  node_type(Types::Models::TimeRecord)
end
