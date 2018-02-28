class UpdatePmpItemMonthlyActuals < ActiveRecord::Migration
  def up
    change_column :pmp_item_monthly_actuals, :start_date, :date
    change_column :pmp_item_monthly_actuals, :end_date, :date
  end

  def down
    change_column :pmp_item_monthly_actuals, :start_date, :datetime
    change_column :pmp_item_monthly_actuals, :end_date, :datetime
  end
end
