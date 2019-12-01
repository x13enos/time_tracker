# Make a customized connection type
class Types::Connections::TimeRecordWithTotalSpentTime < GraphQL::Types::Relay::BaseConnection
  edge_type(Types::Edges::TimeRecord)

  field :total_spent_time, Float, null: false

  def total_spent_time
    object.nodes.sum(:spent_time)
  end
end
