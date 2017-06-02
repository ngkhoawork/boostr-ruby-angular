class CreateTimePeriodWeeks < ActiveRecord::Migration
  def change
    create_table :time_period_weeks do |t|
      t.integer :week
      t.date :start_date
      t.date :end_date
      t.string :period_name
      t.date :period_start
      t.date :period_end

      t.timestamps null: false
    end
  end
end
