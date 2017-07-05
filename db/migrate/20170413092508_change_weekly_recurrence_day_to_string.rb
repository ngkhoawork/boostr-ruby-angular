class ChangeWeeklyRecurrenceDayToString < ActiveRecord::Migration
  def change
    change_column :dfp_report_queries, :weekly_recurrence_day, :string
  end
end
