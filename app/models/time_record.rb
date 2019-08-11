class TimeRecord < ApplicationRecord
  validates :description, :time_start, :spend_time, presence: true

  belongs_to :user
  belongs_to :project
end
