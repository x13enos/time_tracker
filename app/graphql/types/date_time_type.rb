module Types
  class DateTimeType < Types::BaseScalar
    graphql_name 'DateTimeType'
    def self.coerce_input(value, _context)
      Time.zone.at(value.to_i)
    end

    def self.coerce_result(value, _context)
      value.utc.iso8601.to_time.to_i
    end
  end
end
