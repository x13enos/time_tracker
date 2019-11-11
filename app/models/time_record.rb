class TimeRecord < ApplicationRecord
  validates :description, :spent_time, :assigned_date, presence: true
  validate :only_todays_task_could_be_activated, if: :time_start

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
end
