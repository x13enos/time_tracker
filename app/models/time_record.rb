class TimeRecord < ApplicationRecord
  scope :active, -> { where("time_start IS NOT NULL") }

  belongs_to :user
  belongs_to :project
  has_one :workspace, through: :project
  has_and_belongs_to_many :tags, -> { distinct }

  scope :by_workspace, ->(workspace_id) { joins(:project).where("projects.workspace_id = ?", workspace_id) }

  def stop
    time_passed = ((Time.now - time_start) / 3600).round(2)
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
      (passed_time + spent_time).round(2)
    else
      spent_time
    end
  end

  def passed_time
    (Time.now - time_start) / 3600
  end

  def belongs_to_user?(user_id)
    self.user_id == user_id
  end

  def self.total_time
    total_time = all.map(&:spent_time).inject(0, :+)
    if (active_task = all.find_by('time_start IS NOT NULL'))
      total_time += active_task.passed_time
    end
    total_time.round(2)
  end

  def self.by_tags(tags_ids)
    return all if tags_ids.empty?

    joins(:tags).where('tags.id IN (?)', tags_ids)
  end
end
