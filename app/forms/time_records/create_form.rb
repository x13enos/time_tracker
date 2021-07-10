module TimeRecords
  class CreateForm < TimeRecords::BaseForm
    validate :only_todays_task_could_be_activated, if: :time_start
    validate :value_of_spent_time

    def initialize(attributes, user)
      @user = user
      attributes.merge!(workspace_id: user.active_workspace_id)
      super(attributes)
    end

    def save
      if valid?
        create_time_record
        stop_other_launched_time_records
        true
      else
        false
      end
    end

    private

    def create_time_record
      @time_record = user.time_records.create(as_json.slice(*ATTRIBUTES))
      @id = time_record.id
    end
  end
end
