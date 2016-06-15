class AddPreviousStageIdToDealStageLogs < ActiveRecord::Migration
  def change
    add_column :deal_stage_logs, :previous_stage_id, :integer
  end
end
