class CreatePublisherDailyActuals < ActiveRecord::Migration
  def change
    create_table :publisher_daily_actuals do |t|
      t.references :publisher, index: true
      t.date :date
      t.integer :available_impressions
      t.integer :filled_impressions
      t.integer :fill_rate

      t.timestamps null: false
    end
  end
end
