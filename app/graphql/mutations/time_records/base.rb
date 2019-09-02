module Mutations
  module TimeRecords
    class Base < Mutations::BaseMutation

      argument :data, Types::Inputs::TimeRecordData, required: true
      argument :start_task, Boolean, required: false

      field :time_record, Types::Models::TimeRecord, null: false

      private

      def prepared_params(data, start_task)
        params = data.to_h
        time_start_value = start_task ? Time.now : nil
        params.merge!({ time_start: time_start_value })
        return params
      end
    end
  end
end
