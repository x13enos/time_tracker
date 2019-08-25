module Mutations
  module TimeRecords
    class Create < Mutations::BaseMutation
      graphql_name 'TimeRecordCreate'

      argument :data, Types::Inputs::TimeRecordData, required: true

      field :time_record, Types::Models::TimeRecord, null: false

      def resolve(data:)
        authorize('time_record')
        time_record = create_record(data)
        return { time_record: time_record }
      rescue ActiveRecord::RecordInvalid => e
        GraphQL::ExecutionError.new(e)
      end

      private

      def create_record(data)
        record_params = data.to_h.merge(time_start: Time.now)
        context[:current_user].time_records.create!(record_params)
      end
    end
  end
end
