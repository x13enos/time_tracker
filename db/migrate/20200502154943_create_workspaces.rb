class CreateWorkspaces < ActiveRecord::Migration[5.2]
  def change
    create_table :workspaces do |t|
      t.string :name, null: false

      t.timestamps
    end

    create_join_table :workspaces, :users do |t|
      t.index [:workspace_id, :user_id]
      t.index [:user_id, :workspace_id]
    end

    add_column :users, :active_workspace_id, :integer
    add_column :projects, :workspace_id, :integer
  end
end
