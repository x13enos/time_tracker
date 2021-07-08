class AddWorkspaceIdToTimeRecord < ActiveRecord::Migration[6.1]
  def change
    add_column :time_records, :workspace_id, :integer
  end
end
