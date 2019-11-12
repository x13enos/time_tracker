module Types
  module Models
    class TimeRecord < Types::BaseObject
      global_id_field :id
      field :description, String, null: false
      field :time_start, Types::DateTimeType, null: true
      field :spent_time, Float, null: false
      field :user, Types::Models::User, null: false
      field :project, Types::Models::Project, null: false

      def spent_time
        object.active? ? calculated_actual_time : object.spent_time
      end

      private

      def calculated_actual_time
        passed_time_from_start = (Time.zone.now - object.time_start) / 3600
        (passed_time_from_start + object.spent_time).round(2)
      end
    end
  end
end
