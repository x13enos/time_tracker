class TimeRecord < ApplicationRecord
  validates :description, :spent_time, presence: true

  belongs_to :user
  belongs_to :project
end
