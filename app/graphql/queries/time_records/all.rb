module Queries
  module TimeRecords
    class All < Queries::BaseQuery
      argument :from_date, Types::DateType, required: true
      argument :to_date, Types::DateType, required: true
      argument :user_id, ID, required: false, loads: Types::Models::User

      type Types::Connections::TimeRecordWithTotalSpentTime, null: false

      def resolve(from_date:, to_date:, user:)
        authorize('time_record')
        (user || context[:current_user]).
          time_records.
          where("assigned_date BETWEEN ? AND ?", from_date, to_date).
          order(created_at: :desc)
      end
    end
  end
end
