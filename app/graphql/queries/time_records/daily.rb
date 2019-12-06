module Queries
  module TimeRecords
    class Daily < Queries::BaseQuery
      argument :date, Types::DateType, required: true

      type [Types::Models::TimeRecord], null: false

      def resolve(date:)
        authorize('time_record')
        context[:current_user].
          time_records.
          where(assigned_date: date).
          order(created_at: :asc)
      end
    end
  end
end
