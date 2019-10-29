module Types
  module Inputs
    class TimeRecordData < BaseInputObject
      description "Attributes for handling time record"
      argument :assigned_date, Types::DateType, required: false
      argument :description, String, required: true
      argument :spent_time, Float, required: false
    end
  end
end
