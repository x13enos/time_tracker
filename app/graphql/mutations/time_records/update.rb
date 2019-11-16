module Mutations
  module TimeRecords
    class Update < Mutations::TimeRecords::Base
      graphql_name 'TimeRecordUpdate'

      argument :time_record_id, ID, required: true, loads: Types::Models::TimeRecord

      def resolve(time_record:, data:, start_task:, project:)
        authorize(time_record)
        params = prepared_params(data: data, start_task: start_task, project: project)
        time_record.update!(params)
        stop_other_launched_time_records(time_record)
        return { time_record: time_record }
      rescue ActiveRecord::RecordInvalid => e
        GraphQL::ExecutionError.new(handle_invalid_record_message(e))
      end
    end
  end
end
