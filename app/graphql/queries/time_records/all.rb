module Queries
  module TimeRecords
    class All < Queries::BaseQuery
      type [Types::Models::TimeRecord], null: false

      def resolve
        authorize('time_record')
        context[:current_user].time_records.order(created_at: :asc)
      end

    end
  end
end
