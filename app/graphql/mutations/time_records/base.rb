module Mutations
  module TimeRecords
    class Base < Mutations::BaseMutation

      argument :data, Types::Inputs::TimeRecordData, required: true
      argument :start_task, Boolean, required: false
      argument :project_id, ID, required: true, loads: Types::Models::Project

      field :time_record, Types::Models::TimeRecord, null: false
      field :project, Types::Models::Project, null: false

      private

      def prepared_params(data, start_task, project)
        params = data.to_h
        time_start_value = start_task ? Time.now : nil
        params.merge!({
          time_start: time_start_value,
          project_id: project.id 
        })
        return params
      end
    end
  end
end
