class AddNotificationRulesToUserWorkspacesTable < ActiveRecord::Migration[6.0]
  def up
    drop_table :notification_settings
    add_column :users_workspaces, :notification_rules, :jsonb, default: []

    remove_index :users_workspaces, name: "index_users_workspaces_on_user_id_and_workspace_id"
    remove_index :users_workspaces, name: "index_users_workspaces_on_workspace_id_and_user_id"

    add_index :users_workspaces, [:user_id, :workspace_id], unique: true
    add_index :users_workspaces, [:workspace_id, :user_id], unique: true
  end

  def down
    remove_column :users_workspaces, :notification_rules
    create_table :notification_settings do |t|
      t.jsonb :rules, default: []
      t.integer :user_id, null: false

      t.timestamps
    end

    remove_index :users_workspaces, name: "index_users_workspaces_on_user_id_and_workspace_id"
    remove_index :users_workspaces, name: "index_users_workspaces_on_workspace_id_and_user_id"

    add_index :users_workspaces, [:user_id, :workspace_id]
    add_index :users_workspaces, [:workspace_id, :user_id]
  end
end
