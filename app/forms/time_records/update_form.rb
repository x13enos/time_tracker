module TimeRecords
  class UpdateForm < TimeRecords::BaseForm
    validate :only_todays_task_could_be_activated, if: :time_start
    validate :value_of_spent_time

    def initialize(passed_attributes, user, time_record)
      @user = user
      @time_record = time_record
      attributes = time_record.attributes.merge!(passed_attributes)
      super(attributes)
    end

    def save
      if valid?
        update_time_record
        stop_other_launched_time_records
      else
        raise_error
      end
    end

    private

    def update_time_record
      time_record.update(as_json.slice(*ATTRIBUTES))
    end
  end
end
