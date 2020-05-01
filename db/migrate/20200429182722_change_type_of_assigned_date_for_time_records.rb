class ChangeTypeOfAssignedDateForTimeRecords < ActiveRecord::Migration[5.2]
  def up
    change_column :time_records, :assigned_date, :date
  end

  def down
    change_column :time_records, :assigned_date, :timestamp
  end
end
