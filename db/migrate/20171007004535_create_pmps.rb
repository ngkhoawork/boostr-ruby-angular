class CreatePmps < ActiveRecord::Migration
  def change
    create_table :pmps do |t|
      t.belongs_to :company, index: true, foreign_key: true
      t.integer :advertiser_id
      t.integer :agency_id
      t.string :name
      t.decimal :budget, precision: 15, scale: 2
      t.decimal :budget_delivered, precision: 15, scale: 2, precision: 15, scale: 2
      t.decimal :budget_remaining, precision: 15, scale: 2, precision: 15, scale: 2
      t.decimal :budget_loc, precision: 15, scale: 2
      t.decimal :budget_delivered_loc, precision: 15, scale: 2, precision: 15, scale: 2
      t.decimal :budget_remaining_loc, precision: 15, scale: 2
      t.datetime :start_date
      t.datetime :end_date
      t.decimal '7_day_run_rate'
      t.decimal '30_day_run_rate'
      t.string :curr_cd, default: 'USD'
    end
  end
end
