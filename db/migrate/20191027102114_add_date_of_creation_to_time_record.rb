class AddDateOfCreationToTimeRecord < ActiveRecord::Migration[5.2]
  def change
    add_column :time_records, :assigned_date, :date
  end
end
