class TimeRecord < ApplicationRecord
  validates :description, :spent_time, :assigned_date, presence: true
  validate :active_task_launched_today, if: :time_start

  scope :active, -> { where("time_start IS NOT NULL") }

  belongs_to :user
  belongs_to :project

  def stop
    time_passed = ((Time.now - self.time_start) / 3600).round(2)
    self.update!(
      time_start: nil,
      spent_time: self.spent_time + time_passed
    )
  end

  private

  def active_task_launched_today
    if self.assigned_date != Date.today
      errors.add(:time_start, I18n.t("time_records.errors.only_todays_taks"))
    end
  end
end
