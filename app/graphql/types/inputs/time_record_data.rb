module Types
  module Inputs
    class TimeRecordData < BaseInputObject
      description "Attributes for handling time record"
      argument :description, String, required: true
      argument :spent_time, Float, required: false
      argument :project_id, Integer, required: true
    end
  end
end
