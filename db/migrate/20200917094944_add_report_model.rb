class AddReportModel < ActiveRecord::Migration[6.0]
  def change
    create_table :reports do |t|
      t.integer :user_id
      t.string  :uuid

      t.timestamps
    end
  end
end
