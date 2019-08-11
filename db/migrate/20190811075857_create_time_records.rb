class CreateTimeRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :time_records do |t|
      t.integer :project_id, null: false
      t.integer :user_id, null: false
      t.text :description, null: false
      t.datetime :time_start, null: false
      t.integer :spend_time, null: false, default: false

      t.timestamps
    end
  end
end
