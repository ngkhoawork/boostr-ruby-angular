class RenameStageIdForPublisher < ActiveRecord::Migration
  def change
    rename_column :publishers, :stage_id, :publisher_stage_id
  end
end
