class Workspace < ApplicationRecord

  has_and_belongs_to_many :users, -> { distinct }
  has_many :projects, dependent: :destroy

  validates :name, presence: true
end
