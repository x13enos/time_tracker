class TimeRecord < ApplicationRecord
  scope :active, -> { where("time_start IS NOT NULL") }

  belongs_to :user
  belongs_to :project

  def stop
    time_passed = ((Time.zone.now - time_start) / 3600).round(2)
    self.update!(
      time_start: nil,
      spent_time: spent_time + time_passed
    )
  end

  def time_start_as_epoch
    time_start.utc.iso8601.to_time.to_i if time_start
  end

  def active?
    time_start.present?
  end

  def calculated_spent_time
    if active?
      passed_time_from_start = (Time.zone.now - time_start) / 3600
      (passed_time_from_start + spent_time).round(2)
    else
      spent_time
    end
  end

  def belongs_to_user?(user_id)
    self.user_id == user_id
  end
end
