class AddRegexpOfGroupingToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :regexp_of_grouping, :string
  end
end
