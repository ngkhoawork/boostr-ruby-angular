class AddActiveWdayToDealStageLogs < ActiveRecord::Migration
  def change
    add_column :deal_stage_logs, :active_wday, :integer
  end
end
