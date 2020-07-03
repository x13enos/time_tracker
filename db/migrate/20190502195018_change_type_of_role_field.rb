class ChangeTypeOfRoleField < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :role, 'integer USING CAST(role AS integer)'
  end
end
