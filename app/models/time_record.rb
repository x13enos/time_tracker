class TimeRecord < ApplicationRecord
  validates :description, :time_start, :spent_time, presence: true

  belongs_to :user
  belongs_to :project
end
