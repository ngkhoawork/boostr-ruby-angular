class AddPmpItemsColumns < ActiveRecord::Migration
  def change
    unless column_exists? :pmp_items, :start_date
      add_column :pmp_items, :start_date, :date
    end
    unless column_exists? :pmp_items, :end_date
      add_column :pmp_items, :end_date, :date
    end
    unless column_exists? :pmp_items, :delivered
      add_column :pmp_items, :delivered, :decimal, precision: 15, scale: 2
    end
  end
end
