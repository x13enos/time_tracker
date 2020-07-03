module TimeRecords
  class UpdateForm < TimeRecords::BaseForm
    attr_accessor :stop_action

    validate :only_todays_task_could_be_activated, if: :time_start
    validate :value_of_spent_time, unless: :stop_action

    def initialize(passed_attributes, user, time_record)
      @user = user
      @time_record = time_record
      @stop_action = is_it_stop_action?(passed_attributes)
      attributes = time_record.attributes.merge!(passed_attributes)
      super(attributes)
    end

    def save
      if valid?
        update_time_record
        stop_other_launched_time_records
        true
      else
        false
      end
    end

    private

    def update_time_record
      time_record.update(as_json.slice(*ATTRIBUTES))
    end

    def is_it_stop_action?(passed_attributes)
      passed_attributes[:time_start].nil? && time_record.time_start
    end
  end
end
