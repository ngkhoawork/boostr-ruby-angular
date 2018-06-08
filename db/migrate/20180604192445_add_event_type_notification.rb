class AddEventTypeNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :event_type, :integer, default: 0
  end
end
