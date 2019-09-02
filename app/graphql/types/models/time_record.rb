module Types
  module Models
    class TimeRecord < Types::BaseObject
      global_id_field :id
      field :description, String, null: false
      field :time_start, Types::DateTimeType, null: true
      field :spent_time, Float, null: false
      field :user, Types::Models::User, null: false
      field :project, Types::Models::Project, null: false
    end
  end
end
