class CreateEalerts < ActiveRecord::Migration
  def change
    create_table :ealerts do |t|
      t.belongs_to :company, index: true, foreign_key: true
      t.string :recipients
      t.boolean :automatic_send
      t.boolean :same_all_stages
      t.integer :budget, limit: 2, default: 0
      t.integer :flight_date, limit: 2, default: 0
      t.integer :agency, limit: 2, default: 0
      t.integer :deal_type, limit: 2, default: 0
      t.integer :source_type, limit: 2, default: 0
      t.integer :next_steps, limit: 2, default: 0
      t.integer :closed_reason, limit: 2, default: 0
      t.integer :intiative, limit: 2, default: 0
      t.integer :product_name, limit: 2, default: 0
      t.integer :product_budget, limit: 2, default: 0

      t.timestamps null: false
    end
  end
end
