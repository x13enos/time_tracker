module Mutations
  module TimeRecords
    class Create < Mutations::TimeRecords::Base
      graphql_name 'TimeRecordCreate'

      def resolve(data:, start_task:)
        authorize('time_record')
        params = prepared_params(data, start_task)
        time_record = create_record(params)
        return { time_record: time_record }
      rescue ActiveRecord::RecordInvalid => e
        GraphQL::ExecutionError.new(e)
      end

      private

      def create_record(params)
        context[:current_user].time_records.create!(params)
      end
    end
  end
end
