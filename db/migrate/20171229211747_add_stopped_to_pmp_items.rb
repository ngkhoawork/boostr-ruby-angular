class AddStoppedToPmpItems < ActiveRecord::Migration
  def change
    add_column :pmp_items, :is_stopped, :boolean, default: false
    add_column :pmp_items, :stopped_at, :date
  end
end
