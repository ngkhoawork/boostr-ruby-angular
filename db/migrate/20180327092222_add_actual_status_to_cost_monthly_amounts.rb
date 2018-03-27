class AddActualStatusToCostMonthlyAmounts < ActiveRecord::Migration
  def change
    add_column :cost_monthly_amounts, :actual_status, :string, default: CostMonthlyAmount::PENDING
  end
end
