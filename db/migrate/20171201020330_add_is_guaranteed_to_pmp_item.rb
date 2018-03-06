class AddIsGuaranteedToPmpItem < ActiveRecord::Migration
  def change
    add_column :pmp_items, :is_guaranteed, :boolean, default: false
  end
end
