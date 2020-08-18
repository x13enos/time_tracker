class AddRoleToUserWorkspacesTable < ActiveRecord::Migration[6.0]
  def up
    add_column :users_workspaces, :id, :primary_key
    add_column :users_workspaces, :role, :integer, nil: false, default: 0
    remove_column :users, :role
  end

  def down
    remove_column :users_workspaces, :role
    remove_column :users_workspaces, :id
    add_column :users, :role, :string, default: "staff"
  end
end
