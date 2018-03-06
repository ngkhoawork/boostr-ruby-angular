class CreateSalesProcess < ActiveRecord::Migration
  def change
    create_table :sales_processes do |t|
      t.belongs_to :company, index: true, foreign_key: true
      t.string :name
      t.boolean :active, default: true
    end
  end
end
