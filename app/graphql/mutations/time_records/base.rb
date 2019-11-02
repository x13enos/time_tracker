module Mutations
  module TimeRecords
    class Base < Mutations::BaseMutation

      argument :data, Types::Inputs::TimeRecordData, required: true
      argument :start_task, Boolean, required: false
      argument :project_id, ID, required: true, loads: Types::Models::Project

      field :time_record, Types::Models::TimeRecord, null: false
      field :project, Types::Models::Project, null: false

      private

      def prepared_params(data:, start_task:, project:)
        params = data.to_h
        params.merge({
          time_start: time_start_value(start_task),
          project_id: project.id
        })
      end

      def time_start_value(start_task)
        start_task ? Time.now : nil
      end

      def stop_other_launched_time_records(time_record)
        return if time_record.time_start.nil?
        active_time_records = context[:current_user].time_records.active.
                                where("id <> ?", time_record.id)
        active_time_records.each(&:stop)
      end
    end
  end
end
