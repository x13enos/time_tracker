class Tag < ApplicationRecord

  validates :name, presence: true, uniqueness: { scope: :workspace_id }

  has_and_belongs_to_many :time_records, -> { distinct }
  belongs_to :workspace

  scope :by_workspace, ->(workspace_id) { where("workspace_id = ?", workspace_id) }

end
