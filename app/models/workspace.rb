class Workspace < ApplicationRecord
  include TimeTrackerExtension::WorkspaceExtension if EXTENSION_ENABLED

  has_and_belongs_to_many :users, -> { distinct }
  has_many :projects, dependent: :destroy
  has_many :time_records, through: :projects

  validates :name, presence: true

  def belongs_to_user?(user_id)
    self.user_ids.include?(user_id)
  end
end
