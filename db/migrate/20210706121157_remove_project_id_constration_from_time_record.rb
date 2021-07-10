class RemoveProjectIdConstrationFromTimeRecord < ActiveRecord::Migration[6.1]
  def up
    change_column :time_records, :project_id, :integer, null: true
    change_column :time_records, :description, :text, null: true
  end

  def down
    change_column :time_records, :project_id, :integer, null: false
    change_column :time_records, :description, :text, null: false
  end
end
