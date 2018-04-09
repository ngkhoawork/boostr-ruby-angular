class CreatePmpItemMonthlyActuals < ActiveRecord::Migration
  def change
    create_table :pmp_item_monthly_actuals do |t|
    	t.belongs_to :pmp_item, index: true, foreign_key: true
    	t.decimal :amount, precision: 15, scale: 2
    	t.decimal :amount_loc, precision: 15, scale: 2
    	t.datetime :start_date
    	t.datetime :end_date
    end
  end
end
