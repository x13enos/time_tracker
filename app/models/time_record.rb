class TimeRecord < ApplicationRecord
  validates :description, :spent_time, :assigned_date, presence: true
  validate :only_todays_task_could_be_activated, if: :time_start
  validate :value_of_spent_time, if: :spent_time

  scope :active, -> { where("time_start IS NOT NULL") }

  belongs_to :user
  belongs_to :project

  def stop
    time_passed = ((Time.zone.now - self.time_start) / 3600).round(2)
    self.update!(
      time_start: nil,
      spent_time: self.spent_time + time_passed
    )
  end

  def active?
    time_start.present?
  end

  private

  def only_todays_task_could_be_activated
    if self.assigned_date != Time.zone.today
      errors.add(:time_start, I18n.t("time_records.errors.only_todays_taks"))
    end
  end

  def value_of_spent_time
    days_tasks = TimeRecord.where(assigned_date: assigned_date)
    days_tasks = days_tasks.where.not(id: id) if id
    if (days_tasks.sum(:spent_time) + spent_time) > 24.0
      errors.add(:spent_time, I18n.t("time_records.errors.should_be_less_than_24_hours"))
    end
  end
end
