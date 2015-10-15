class CreateClientTypes < ActiveRecord::Migration
  def change
    create_table :client_types do |t|
      t.integer :company_id
      t.string :name
      t.integer :position
      t.datetime :deleted_at

      t.timestamps null: false
    end

    remove_column :clients, :client_type
    add_column :clients, :client_type_id, :integer

    add_index :clients, :client_type_id
    add_index :client_types, [:id, :company_id, :position, :deleted_at], name: 'index_client_types_composite'
  end
end
