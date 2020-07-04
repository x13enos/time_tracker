class AddNotNullConstraintsAboutWorkspace < ActiveRecord::Migration[5.2]
  def change
    change_column_null(:users, :active_workspace_id, true)
    change_column_null(:projects, :workspace_id, true)
    change_column_null(:tags, :workspace_id, true)
  end
end
