class CreateTimeRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :time_records do |t|
      t.integer :project_id, null: false
      t.integer :user_id, null: false
      t.text :description, null: false
      t.datetime :time_start, null: false
      t.float :spent_time, null: false, default: 0.0

      t.timestamps
    end
  end
end
