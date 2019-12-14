module Mutations
  module Reports
    class Generate < Mutations::BaseMutation
      graphql_name 'ReportGenerate'

      argument :from_date, Types::DateType, required: true
      argument :to_date, Types::DateType, required: true
      argument :user_id, ID, required: true, loads: Types::Models::User

      field :link, String, null: false

      def resolve(time_records_data)
        authorize("report")
        generator = ReportGenerator.new(time_records_data)
        { link: generator.perform }
      end
    end
  end
end
