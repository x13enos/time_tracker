module Types
  module Inputs
    class TimeRecordData < BaseInputObject
      description "Attributes for handling time record"
      argument :description, String, required: true
      argument :spent_time, Float, required: false
    end
  end
end
