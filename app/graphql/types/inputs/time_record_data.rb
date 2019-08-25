module Types
  module Inputs
    class TimeRecordData < BaseInputObject
      description "Attributes for handling time record"
      argument :description, String, required: true
      argument :spent_time, Float, required: true
      argument :project_id, Integer, required: true
    end
  end
end
