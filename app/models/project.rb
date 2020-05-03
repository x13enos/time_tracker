class Project < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_and_belongs_to_many :users, -> { distinct }
  has_many :time_records, dependent: :destroy
  belongs_to :workspace

  scope :by_workspace, ->(workspace_id) { where("workspace_id = ?", workspace_id) }

  def belongs_to_user?(user_id)
    self.user_ids.include?(user_id)
  end
end
