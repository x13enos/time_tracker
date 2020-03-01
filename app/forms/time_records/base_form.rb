module TimeRecords
  class BaseForm
    include ActiveModel::Model

    validates :description, :spent_time, :assigned_date, presence: true

    ATTRIBUTES = %w[name spent_time time_start description assigned_date
                 project_id user_id created_at updated_at]

    attr_accessor *ATTRIBUTES
    attr_accessor :id, :user, :time_record

    private

    def stop_other_launched_time_records
      return if time_start.nil?
      active_time_records = user.time_records.active.where("id <> ?", id)
      active_time_records.each(&:stop)
    end

    def only_todays_task_could_be_activated
      if Time.zone.parse(assigned_date.to_s) != Time.zone.today.beginning_of_day
        self.errors.add(:base, I18n.t("time_records.errors.only_todays_taks"))
      end
    end

    def value_of_spent_time
      local_assigned_date = Time.zone.parse(assigned_date.to_s)
      day_tasks = user.time_records.where("time_records.assigned_date BETWEEN ? AND ?", local_assigned_date.beginning_of_day, local_assigned_date.end_of_day)
      day_tasks = day_tasks.where.not(id: id) if id
      if (day_tasks.sum(:spent_time) + spent_time.to_f) > 24.0
        self.errors.add(:base, I18n.t("time_records.errors.should_be_less_than_24_hours"))
      end
    end
  end
end
