class CreatePmpItems < ActiveRecord::Migration
  def change
    create_table :pmp_items do |t|
    	t.belongs_to :pmp, index: true, foreign_key: true
    	t.belongs_to :ssp, index: true, foreign_key: true
    	t.string :deal_id
    	t.decimal :budget, precision: 15, scale: 2
    	t.decimal :budget_delivered, precision: 15, scale: 2
    	t.decimal :budget_remaining, precision: 15, scale: 2
    	t.decimal :budget_loc, precision: 15, scale: 2
    	t.decimal :budget_delivered_loc, precision: 15, scale: 2
    	t.decimal :budget_remaining_loc, precision: 15, scale: 2
    end
  end
end
