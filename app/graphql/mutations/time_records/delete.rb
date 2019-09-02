module Mutations
  module TimeRecords
    class Delete < Mutations::BaseMutation
      graphql_name 'TimeRecordDelete'

      argument :time_record_id, ID, required: true, loads: Types::Models::TimeRecord

      field :time_record, Types::Models::TimeRecord, null: true

      def resolve(time_record:)
        authorize(time_record)
        time_record.destroy
        return { time_record: time_record }
      rescue ActiveRecord::RecordInvalid => e
        GraphQL::ExecutionError.new(e)
      end

    end
  end
end
