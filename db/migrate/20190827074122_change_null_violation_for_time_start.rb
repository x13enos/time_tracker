class ChangeNullViolationForTimeStart < ActiveRecord::Migration[5.2]
  def up
    change_column :time_records, :time_start, :datetime, null: true
  end

  def down
    change_column :time_records, :time_start, :datetime, null: false
  end
end
