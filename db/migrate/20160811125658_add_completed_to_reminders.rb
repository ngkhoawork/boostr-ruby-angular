class AddCompletedToReminders < ActiveRecord::Migration
  def change
    add_column :reminders, :completed, :boolean
  end
end
