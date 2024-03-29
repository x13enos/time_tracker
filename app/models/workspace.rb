class Workspace < ApplicationRecord
  include TimeTrackerExtension::WorkspaceExtension if EXTENSION_ENABLED

  has_many :users_workspaces, dependent: :destroy
  has_many :users, -> { distinct }, through: :users_workspaces
  has_many :projects, dependent: :destroy
  has_many :time_records

  validates :name, presence: true

  def belongs_to_user?(user_id)
    self.user_ids.include?(user_id)
  end

end
