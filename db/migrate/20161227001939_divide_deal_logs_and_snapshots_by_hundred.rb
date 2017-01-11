class DivideDealLogsAndSnapshotsByHundred < ActiveRecord::Migration
  def up
    DealLog.where.not(budget_change: nil).update_all('budget_change = budget_change / 100')
  end

  def down
    DealLog.where.not(budget_change: nil).update_all('budget_change = budget_change * 100')
  end
end
