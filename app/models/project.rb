class Project < ApplicationRecord
  validates :name, presence: true, uniqueness: { scope: :workspace_id }
  validate :regexp_should_be_valid, if: :regexp_of_grouping

  has_and_belongs_to_many :users, -> { distinct }
  has_many :time_records, dependent: :destroy
  belongs_to :workspace

  scope :by_workspace, ->(workspace_id) { where("workspace_id = ?", workspace_id) }

  def belongs_to_user?(user_id)
    self.user_ids.include?(user_id)
  end

  private

  def regexp_should_be_valid
    Regexp.new(self.regexp_of_grouping)
  rescue RegexpError => e
    errors.add(:regexp_of_grouping, I18n.t("projects.errors.incorrect_format_of_regexp"))
  end
end
