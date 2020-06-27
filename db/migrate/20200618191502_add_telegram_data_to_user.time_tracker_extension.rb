# This migration comes from time_tracker_extension (originally 20200618101401)
class AddTelegramDataToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :telegram_token, :string
    add_column :users, :telegram_id, :integer

    add_index :users, :telegram_token, unique: true
    add_index :users, :telegram_id, unique: true
  end
end
