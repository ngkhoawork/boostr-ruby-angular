class CreateDfpReportQueries < ActiveRecord::Migration
  def change
    create_table :dfp_report_queries do |t|
      t.integer :report_type
      t.integer :weekly_recurrence_day
      t.integer :monthly_recurrence_day
      t.string  :report_id
      t.boolean :is_daily_recurrent, default: false
      t.references :api_configuration, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
