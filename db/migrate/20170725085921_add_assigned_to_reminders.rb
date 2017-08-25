class AddAssignedToReminders < ActiveRecord::Migration
  def change
    add_column :reminders, :assigned, :boolean
  end
end
