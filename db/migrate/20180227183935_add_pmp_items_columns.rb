class AddPmpItemsColumns < ActiveRecord::Migration
  def change
    add_column :pmp_items, :start_date, :date
    add_column :pmp_items, :end_date, :date
    add_column :pmp_items, :delivered, :decimal, precision: 15, scale: 2
  end
end
