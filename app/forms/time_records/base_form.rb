module TimeRecords
  class BaseForm
    include ActiveModel::Model
    include TimeTrackerExtension::TimeRecords::BaseFormExtension if EXTENSION_ENABLED

    validates :workspace_id, :spent_time, :assigned_date, presence: true

    ATTRIBUTES = %w[name spent_time time_start description assigned_date
                 project_id user_id created_at updated_at tag_ids workspace_id]

    attr_accessor *ATTRIBUTES
    attr_accessor :id, :user, :time_record, :start_task

    private

    def stop_other_launched_time_records
      return unless start_task
      active_time_records = user.time_records.active.where("id <> ?", id)
      active_time_records.each(&:stop)
    end

    def only_todays_task_could_be_activated
      if assigned_date.to_date != Time.zone.today
        self.errors.add(:base, I18n.t("time_records.errors.only_todays_taks"))
      end
    end

    def value_of_spent_time
      day_tasks = user.time_records.where("time_records.assigned_date = ?", assigned_date)
      day_tasks = day_tasks.where.not(id: id) if id
      if (day_tasks.sum(:spent_time) + spent_time.to_f) > 24.0
        self.errors.add(:spent_time, I18n.t("time_records.errors.should_be_less_than_24_hours"))
      end
    end
  end
end
