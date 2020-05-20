class CreateTags < ActiveRecord::Migration[5.2]
  def change
    create_table :tags do |t|
      t.string :name
      t.integer :workspace_id

      t.timestamps
    end

    create_join_table :tags, :time_records do |t|
      t.index [:tag_id, :time_record_id]
      t.index [:time_record_id, :tag_id]
    end
  end
end
