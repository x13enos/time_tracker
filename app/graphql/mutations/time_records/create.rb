module Mutations
  module TimeRecords
    class Create < Mutations::TimeRecords::Base
      graphql_name 'TimeRecordCreate'

      def resolve(data:, start_task:, project:)
        authorize('time_record')
        params = prepared_params(data: data, start_task: start_task, project: project)
        time_record = create_record(params)
        stop_other_launched_time_records(time_record)
        return { time_record: time_record }
      rescue ActiveRecord::RecordInvalid => e
        GraphQL::ExecutionError.new(handle_invalid_record_message(e))
      end

      private

      def create_record(params)
        context[:current_user].time_records.create!(params)
      end
    end
  end
end
