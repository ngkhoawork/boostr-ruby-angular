class AddPreviousStageToDeals < ActiveRecord::Migration
  def change
    add_column :deals, :previous_stage_id, :integer
  end
end
