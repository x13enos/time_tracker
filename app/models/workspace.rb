class Workspace < ApplicationRecord

  has_and_belongs_to_many :users, -> { distinct }
  has_many :projects, dependent: :destroy

  validates :name, presence: true

  def belongs_to_user?(user_id)
    self.user_ids.include?(user_id)
  end
end
