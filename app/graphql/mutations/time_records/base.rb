module Mutations
  module TimeRecords
    class Base < Mutations::BaseMutation

      argument :data, Types::Inputs::TimeRecordData, required: true
      argument :start_task, Boolean, required: false

      field :time_record, Types::Models::TimeRecord, null: false

      private

      def prepared_params(data, start_task)
        params = data.to_h
        params.merge!({ time_start: Time.now }) if start_task
        return params
      end
    end
  end
end
