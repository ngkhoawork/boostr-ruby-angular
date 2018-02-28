class CreatePmpItemDailyActuals < ActiveRecord::Migration
  def change
    create_table :pmp_item_daily_actuals do |t|
    	t.belongs_to :pmp_item, index: true, foreign_key: true
    	t.date :date
    	t.string :ad_unit
    	t.decimal :price, precision: 15, scale: 2
    	t.decimal :revenue, precision: 15, scale: 2
    	t.decimal :revenue_loc, precision: 15, scale: 2
    	t.integer :impressions
    	t.decimal :win_rate
    end
  end
end
