class CreateSalesProcess < ActiveRecord::Migration
  def change
    create_table :sales_processes do |t|
      t.belongs_to :company, index: true, foreign_key: true
      t.string :name
      t.boolean :active, default: true
      t.datetime :deleted_at
    end

    add_index :sales_processes, [:company_id, :name], unique: true
    add_index :sales_processes, :deleted_at
  end
end
