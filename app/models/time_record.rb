class TimeRecord < ApplicationRecord
  validates :description, :spent_time, :assigned_date, presence: true

  belongs_to :user
  belongs_to :project
end
