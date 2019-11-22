class TimeRecord < ApplicationRecord
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
end
