module Types
  class DateType < Types::BaseScalar
    graphql_name 'DateType'
    def self.coerce_input(value, _context)
      Time.zone.at(value.to_i).to_date
    end
  end
end
