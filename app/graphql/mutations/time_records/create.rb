module Mutations
  module TimeRecords
    class Create < Mutations::TimeRecords::Base
      graphql_name 'TimeRecordCreate'

      def resolve(data:, start_task:, project:)
        authorize('time_record')
        params = prepared_params(data: data, start_task: start_task, project: project)
        form = ::TimeRecords::CreateForm.new(params, context[:current_user])
        form.save
        return { time_record: form.time_record }
      end
    end
  end
end
