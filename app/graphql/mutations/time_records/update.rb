module Mutations
  module TimeRecords
    class Update < Mutations::TimeRecords::Base
      graphql_name 'TimeRecordUpdate'

      argument :time_record_id, ID, required: true, loads: Types::Models::TimeRecord

      def resolve(time_record:, data:, start_task:, project:)
        authorize(time_record)
        params = prepared_params(data: data, start_task: start_task, project: project)
        form = ::TimeRecords::UpdateForm.new(params, context[:current_user], time_record)
        form.save
        return { time_record: form.time_record }
      end
    end
  end
end
