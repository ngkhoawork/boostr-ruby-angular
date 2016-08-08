class AddDeletedAtToReminders < ActiveRecord::Migration
  def change
    add_column :reminders, :deleted_at, :datetime
    add_index :reminders, :deleted_at
  end
end
